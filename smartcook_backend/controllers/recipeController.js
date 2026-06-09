const Recipe = require('../models/Recipe');
const Aliment = require('../models/Aliment');
const Profile = require('../models/Profile');
const aiService = require('../services/aiService');
const imageService = require('../services/recipeImageAiService');
const matchingService = require('../services/matchingService');

const normalizeText = (value) => {
    return String(value || '')
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9\s]/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();
};

const normalizeUnit = (value) => {
    const unit = normalizeText(value);
    if (['g', 'gr', 'gramme', 'grammes', 'gram', 'grams'].includes(unit)) return { key: 'g', factor: 1 };
    if (['kg', 'kilo', 'kilos', 'kilogramme', 'kilogrammes'].includes(unit)) return { key: 'g', factor: 1000 };
    if (['ml', 'millilitre', 'millilitres'].includes(unit)) return { key: 'ml', factor: 1 };
    if (['l', 'litre', 'litres'].includes(unit)) return { key: 'ml', factor: 1000 };
    if (['piece', 'pieces', 'pcs', 'pc', 'unite', 'unites'].includes(unit)) return { key: 'piece', factor: 1 };
    return { key: unit || 'unit', factor: 1 };
};

const parseRecipeIngredients = (value) => {
    if (!value) return [];

    let parsed = value;
    if (typeof value === 'string') {
        try {
            parsed = JSON.parse(value);
        } catch (_) {
            return [];
        }
    }

    if (!Array.isArray(parsed)) return [];

    return parsed
        .map((ingredient) => ({
            nom: String(ingredient?.nom || '').trim(),
            quantite: Number(ingredient?.quantite) || 0,
            unite: String(ingredient?.unite || '').trim()
        }))
        .filter((ingredient) => ingredient.nom);
};

const sameIngredientName = (left, right) => {
    const a = normalizeText(left);
    const b = normalizeText(right);
    return a && b && (a === b || a.includes(b) || b.includes(a));
};

const isAvailableStatus = (aliment) => ['disponible', 'available'].includes(
    String(aliment.statut || '').toLowerCase()
) && Number(aliment.quantite) > 0;

const toBaseQuantity = (quantity, unit) => {
    const normalized = normalizeUnit(unit);
    return {
        key: normalized.key,
        value: (Number(quantity) || 0) * normalized.factor
    };
};

const fromBaseQuantity = (baseValue, unit) => {
    const normalized = normalizeUnit(unit);
    return baseValue / normalized.factor;
};

const formatDateForUpdate = (value) => {
    if (!value) return null;
    if (value instanceof Date) return value.toISOString().split('T')[0];
    return String(value).split('T')[0];
};

const mergeIngredientsByName = (ingredients) => {
    const merged = new Map();

    for (const ingredient of ingredients) {
        const key = `${normalizeText(ingredient.nom)}|${normalizeUnit(ingredient.unite).key}`;
        const existing = merged.get(key);
        if (existing) {
            existing.quantite += ingredient.quantite;
        } else {
            merged.set(key, { ...ingredient });
        }
    }

    return Array.from(merged.values());
};

exports.refreshRecipes = async (req, res) => {
    try {
        const userId = req.userId;

        const profile = await Profile.getByUserId(userId);
        const allAliments = await Aliment.findAllByUser(userId);
        const isAvailable = isAvailableStatus;
        const availableIngredients = allAliments.filter(isAvailable);
        const missingIngredients = allAliments.filter(a => !isAvailable(a));

        if (availableIngredients.length < 2) {
            return res.status(400).json({ message: "Add at least 2 ingredients." });
        }

        const generatedRecipes = await aiService.generateRecipesFromData(
            profile,
            availableIngredients,
            missingIngredients
        );

        if (!generatedRecipes || generatedRecipes.length === 0) {
            return res.status(500).json({ message: "AI could not generate recipes." });
        }

        // 1. Recalculer le vrai score de compatibilité
        for (let recipe of generatedRecipes) {
            recipe.scoreCompatibilite = matchingService.calculateMatchingScore(
                recipe,
                profile,
                availableIngredients
            );
        }

        // 2. Garder les 3 a 5 meilleures recettes compatibles
        const filteredRecipes = generatedRecipes
            .sort((a, b) => b.scoreCompatibilite - a.scoreCompatibilite)
            .slice(0, 5);

        if (filteredRecipes.length === 0) {
            return res.status(400).json({
                message: "No recipe is compatible with your profile."
            });
        }

        // 3. Trier : meilleur score en haut
        // 4. Générer les images seulement pour les recettes acceptées
        let index = 0;
        for (let recipe of filteredRecipes) {
            const localImageUrl = await imageService.generateRecipeImage(recipe, req, index);
            recipe.imageUrl = localImageUrl;
            index++;
        }

        // 5. Sauvegarder en BDD
        await Recipe.deleteAllByUserId(userId);

        const recipesToSave = filteredRecipes.map(r => [
            userId,
            r.nom,
            r.imageUrl,
            r.typeRepas,
            r.tempsPreparation,
            r.difficulte,
            r.nbPersonnes,
            JSON.stringify(r.ingredientsDisponibles || []),
            JSON.stringify(r.ingredientsManquants || []),
            r.etapes,
            r.calories,
            r.proteines,
            r.glucides,
            r.lipides,
            r.benefices,
            r.conseilsSante,
            r.scoreCompatibilite
        ]);

        await Recipe.bulkCreate(recipesToSave);

        res.json({
            message: "New recipes generated!",
            recipes: filteredRecipes
        });

    } catch (error) {
        console.error("Refresh Error:", error);
        res.status(500).json({ error: error.message });
    }
};

exports.prepareRecipe = async (req, res) => {
    try {
        const userId = req.userId;
        const recipeId = req.params.id;

        const recipe = await Recipe.findByIdForUser(recipeId, userId);
        if (!recipe) {
            return res.status(404).json({ message: "Recipe not found." });
        }

        const requiredIngredients = mergeIngredientsByName([
            ...parseRecipeIngredients(recipe.ingredientsDisponibles),
            ...parseRecipeIngredients(recipe.ingredientsManquants)
        ]);

        if (requiredIngredients.length === 0) {
            return res.status(400).json({
                message: "This recipe does not contain a usable ingredient list."
            });
        }

        const allAliments = await Aliment.findAllByUser(userId);
        const availableAliments = allAliments.filter(isAvailableStatus);
        const missingCreated = [];
        const consumed = [];

        for (const required of requiredIngredients) {
            let needed = toBaseQuantity(required.quantite, required.unite);
            if (needed.value <= 0) {
                needed = { ...needed, value: 1 };
            }

            const candidates = availableAliments.filter((aliment) => {
                const inventoryQuantity = toBaseQuantity(aliment.quantite, aliment.unite);
                return sameIngredientName(aliment.nom, required.nom) &&
                    inventoryQuantity.key === needed.key &&
                    inventoryQuantity.value > 0;
            });

            for (const aliment of candidates) {
                if (needed.value <= 0) break;

                const inventoryQuantity = toBaseQuantity(aliment.quantite, aliment.unite);
                const used = Math.min(inventoryQuantity.value, needed.value);
                const remainingBase = inventoryQuantity.value - used;
                const remaining = fromBaseQuantity(remainingBase, aliment.unite);
                const nextStatus = remainingBase <= 0.000001 ? 'missing' : 'disponible';

                await Aliment.update(aliment.id, userId, {
                    ...aliment,
                    dateExpiration: formatDateForUpdate(aliment.dateExpiration),
                    quantite: Math.max(0, remaining),
                    statut: nextStatus
                });

                aliment.quantite = Math.max(0, remaining);
                aliment.statut = nextStatus;
                needed.value -= used;

                consumed.push({
                    nom: aliment.nom,
                    quantite: fromBaseQuantity(used, aliment.unite),
                    unite: aliment.unite
                });
            }

            if (needed.value > 0.000001) {
                const missingQuantity = fromBaseQuantity(needed.value, required.unite);
                const existingMissing = allAliments.find((aliment) => {
                    const alimentQuantity = toBaseQuantity(aliment.quantite, aliment.unite);
                    return !isAvailableStatus(aliment) &&
                        sameIngredientName(aliment.nom, required.nom) &&
                        alimentQuantity.key === needed.key;
                });

                if (existingMissing) {
                    const missingInExistingUnit = fromBaseQuantity(needed.value, existingMissing.unite);
                    await Aliment.update(existingMissing.id, userId, {
                        ...existingMissing,
                        dateExpiration: formatDateForUpdate(existingMissing.dateExpiration),
                        quantite: (Number(existingMissing.quantite) || 0) + missingInExistingUnit,
                        statut: 'missing'
                    });
                    existingMissing.quantite = (Number(existingMissing.quantite) || 0) + missingInExistingUnit;
                    existingMissing.statut = 'missing';
                } else {
                    const newId = await Aliment.create(userId, {
                        nom: required.nom,
                        quantite: missingQuantity,
                        unite: required.unite || 'pcs',
                        type: 'Shopping',
                        dateExpiration: null,
                        statut: 'missing'
                    });
                    allAliments.push({
                        id: newId,
                        nom: required.nom,
                        quantite: missingQuantity,
                        unite: required.unite || 'pcs',
                        statut: 'missing'
                    });
                }

                missingCreated.push({
                    nom: required.nom,
                    quantite: missingQuantity,
                    unite: required.unite || 'pcs'
                });
            }
        }

        res.json({
            message: "Recipe prepared. Inventory updated and missing ingredients added to the list.",
            consumed,
            missing: missingCreated
        });
    } catch (error) {
        console.error("Prepare Recipe Error:", error);
        res.status(500).json({ error: error.message });
    }
};
