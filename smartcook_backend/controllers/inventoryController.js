const Aliment = require('../models/Aliment');

// Fonction centralisée de l'équipe pour récupérer proprement l'ID utilisateur
const getUserId = (req) => {
    const id = req.userId || (req.user ? req.user.id : null);
    if (!id) return null;
    return parseInt(id);
};

// ==========================================
// 1. RÉCUPÉRATION DE L'INVENTAIRE
// ==========================================
const getAllIngredients = async (req, res) => {
    try {
        const userId = getUserId(req);
        if (!userId) return res.status(401).json({ message: 'Non autorisé' });

        console.log("Récupération des ingrédients pour l'user ID :", userId);
        
        const ingredients = await Aliment.findAllByUser(userId);
        res.status(200).json(ingredients);
    } catch (error) {
        console.error("ERREUR GET INVENTORY:", error);
        res.status(500).json({ message: 'Server error while loading inventory', error: error.message });
    }
};


const addIngredient = async (req, res) => {
  try {
    const { nom, quantite, unite, type, dateExpiration } = req.body;

    if (!nom || quantite === undefined || quantite === null || quantite === '' || !unite || !type) {
      return res.status(400).json({
        message: 'Name, quantity, unit, and type are required'
      });
    }

    //  NOUVEAU :
    // conversion du userId en nombre entier
    const userId = parseInt(req.userId);

    //  Création aliment lié à l'utilisateur connecté
    const id = await Aliment.create(userId, req.body);

    res.status(201).json({
      message: 'Ingredient added successfully',
      id
    });

  } catch (error) {
    console.error("ADD INGREDIENT ERROR:", error);

    res.status(500).json({
      message: 'Server error'
    });
  }
};

// ==========================================
// 3. MODIFICATION D'UN INGRÉDIENT
// ==========================================
const updateIngredient = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = getUserId(req);

    //  NOUVEAU :
    // vérifie si utilisateur connecté
    if (!userId) {
      return res.status(401).json({
        message: 'Unauthorized'
      });
    }

    //  Vérifie que l'aliment
    // appartient bien à cet utilisateur
    const belongsToUser = await Aliment.belongsToUser(id, userId);

    // NOUVEAU :
    // message plus précis et sécurisé
    if (!belongsToUser) {
      return res.status(403).json({
        message: 'This ingredient does not belong to you'
      });
    }

        console.log("UPDATE PARAMS:", { id, userId });

        const updated = await Aliment.update(id, userId, req.body);

    if (updated) {
      res.json({
        message: 'Ingredient updated successfully'
      });
    } else {
      res.status(404).json({
        message: 'Ingredient not found'
      });
    }

  } catch (error) {
    console.error("UPDATE INGREDIENT ERROR:", error);

    res.status(500).json({
      message: 'Server error'
    });
  }
};

// ==========================================
// 4. SUPPRESSION D'UN INGRÉDIENT
// ==========================================
const deleteIngredient = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = getUserId(req);

        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const deleted = await Aliment.delete(id, userId);

    if (deleted) {
      res.json({
        message: 'Ingredient deleted successfully'
      });
    } else {
      res.status(404).json({
        message: 'Ingredient not found'
      });
    }

  } catch (error) {
    console.error("DELETE INGREDIENT ERROR:", error);

    res.status(500).json({
      message: 'Server error'
    });
  }
};

module.exports = {
    getAllIngredients,
    getInventory: getAllIngredients,
    addIngredient,
    addItem: addIngredient,
    updateIngredient,
    updateItem: updateIngredient,
    deleteIngredient,
    deleteItem: deleteIngredient,
};
