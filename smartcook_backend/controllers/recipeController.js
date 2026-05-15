const Recipe = require('../models/Recipe');
const Aliment = require('../models/Aliment');
const Profile = require('../models/Profile');
const aiService = require('../services/aiService');

exports.refreshRecipes = async (req, res) => {
    try {
        const userId = req.userId; // Récupéré par ton middleware auth

        // 1. Lire le Profil en BDD
        const profile = await Profile.getByUserId(userId);

        // 2. Lire les Aliments DISPONIBLES en BDD
        const allAliments = await Aliment.findAllByUser(userId);
        const availableIngredients = allAliments.filter(a => a.statut === 'disponible');

        if (availableIngredients.length < 2) {
            return res.status(400).json({ message: "Ajoutez au moins 2 ingrédients pour générer des recettes." });
        }

        // 3. Appeler l'IA avec ces données réelles
        const generatedRecipes = await aiService.generateRecipesFromData(profile, availableIngredients);

        if (!generatedRecipes) {
            return res.status(500).json({ message: "L'IA n'a pas pu générer de recettes." });
        }

        // 4. Nettoyer les anciennes recettes et sauvegarder les nouvelles
        await Recipe.deleteAllByUserId(userId);
        
        const recipesToSave = generatedRecipes.map(r => [
            userId, r.nom, r.imageUrl, r.typeRepas, r.tempsPreparation, r.difficulte, 
            r.nbPersonnes, r.etapes, r.calories, r.proteines, r.glucides, 
            r.lipides, r.benefices, r.conseilsSante, r.scoreCompatibilite
        ]);

        await Recipe.bulkCreate(recipesToSave);

        res.json({ message: "Nouvelles recettes générées !", recipes: generatedRecipes });

    } catch (error) {
        console.error("Refresh Error:", error);
        res.status(500).json({ error: error.message });
    }
};