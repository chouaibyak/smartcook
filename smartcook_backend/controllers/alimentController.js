const Aliment = require('../models/Aliment');
const nutritionService = require('../services/nutritionService');


// Utilitaire pour extraire l'ID utilisateur
const getUserId = (req) => {
    const id = req.userId || (req.user ? req.user.id : null);
    if (!id) return null; // Ne pas retourner 1 !
    return parseInt(id);
};

exports.getNutritionInfo = async (req, res) => {
  try {
const { name, type } = req.query;
    // 1. Validation simple
    if (!name || name.trim() === "") {
      return res.status(400).json({ error: "Ingredient name is required" });
    }

    // 2. Appel au service
const nutrition = await nutritionService.analyzeIngredient(name, type);
    // 3. Si le service a retourné une erreur 503 (gérée dans le service)
    if (nutrition.error) {
      return res.status(503).json({ 
        message: "OpenFoodFacts is unavailable, but you can enter the details manually.",
        details: nutrition.error 
      });
    }

    // 4. Renvoi des données
    console.log("Données envoyées au client :", nutrition);
    res.json(nutrition);

  } catch (error) {
    console.error("Erreur contrôleur nutrition:", error.message);
    res.status(500).json({ error: "Unable to retrieve nutrition information" });
  }
};

exports.saveAliment = async (req, res) => {
  try {
    const data = req.body;

    console.log("DATA RECUE:", data);
    const userId = parseInt(req.userId);

    console.log("DEBUG: Tentative de sauvegarde pour User ID :", userId);

    if (!userId || isNaN(userId)) {
        return res.status(401).json({ error: "User is not authenticated (invalid ID)" });
    }
    
    // Validation minimale
    if (!data.nom) {
      return res.status(400).json({ error: "Name is required to save" });
    }

    // Utilisation de await au lieu du callback
    const newId = await Aliment.create(userId, data);
    
    res.status(201).json({ 
      message: "Ingredient saved!",
      id: newId 
    });

  } catch (error) {
    console.error("Erreur sauvegarde aliment:", error);
    res.status(500).json({ error: "Error while saving to the database" });
  }
};
