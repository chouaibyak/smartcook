const Aliment = require('../models/Aliment');
const nutritionService = require('../services/nutritionService');

exports.getNutritionInfo = async (req, res) => {
  try {
    const { name } = req.query;

    // 1. Validation simple
    if (!name || name.trim() === "") {
      return res.status(400).json({ error: "Le nom de l'aliment est requis" });
    }

    // 2. Appel au service
    const nutrition = await nutritionService.analyzeIngredient(name);

    // 3. Si le service a retourné une erreur 503 (gérée dans le service)
    if (nutrition.error) {
      return res.status(503).json({ 
        message: "OpenFoodFacts est indisponible, mais vous pouvez entrer les infos manuellement.",
        details: nutrition.error 
      });
    }

    // 4. Renvoi des données
    console.log("Données envoyées au client :", nutrition);
    res.json(nutrition);

  } catch (error) {
    console.error("Erreur contrôleur nutrition:", error.message);
    res.status(500).json({ error: "Impossible de récupérer les infos nutritionnelles" });
  }
};

exports.saveAliment = async (req, res) => {
  try {
    const data = req.body;
    
    // Validation minimale
    if (!data.nom) {
      return res.status(400).json({ error: "Le nom est obligatoire pour sauvegarder" });
    }

    // Utilisation de await au lieu du callback
    const result = await Aliment.create(data);
    
    res.status(201).json({ 
      message: "Ingrédient sauvegardé !", 
      id: result.insertId 
    });

  } catch (error) {
    console.error("Erreur sauvegarde aliment:", error);
    res.status(500).json({ error: "Erreur lors de la sauvegarde en base de données" });
  }
};