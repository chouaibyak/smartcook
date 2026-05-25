const Recipe = require('../models/Recipe');
const Aliment = require('../models/Aliment');
const Profile = require('../models/Profile');
const aiService = require('../services/aiService');
const imageService = require('../services/recipeImageAiService');
const matchingService = require('../services/matchingService');

exports.refreshRecipes = async (req, res) => {
    try {
        const userId = req.userId;

        const profile = await Profile.getByUserId(userId);
        const allAliments = await Aliment.findAllByUser(userId);
        const availableIngredients = allAliments.filter(a => a.statut === 'disponible');
        const missingIngredients = allAliments.filter(a => a.statut !== 'disponible');

        if (availableIngredients.length < 2) {
            return res.status(400).json({ message: "Ajoutez au moins 2 ingrédients." });
        }

        const generatedRecipes = await aiService.generateRecipesFromData(
            profile,
            availableIngredients,
            missingIngredients
        );

        if (!generatedRecipes || generatedRecipes.length === 0) {
            return res.status(500).json({ message: "L'IA n'a pas pu générer de recettes." });
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
                message: "Aucune recette compatible avec votre profil."
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
            message: "Nouvelles recettes générées !",
            recipes: filteredRecipes
        });

    } catch (error) {
        console.error("Refresh Error:", error);
        res.status(500).json({ error: error.message });
    }
};
