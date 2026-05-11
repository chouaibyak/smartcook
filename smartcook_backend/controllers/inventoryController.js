const Aliment = require('../models/Aliment');


const getUserId = (req) => {
    const id = req.userId || (req.user ? req.user.id : null);
    if (!id) return null; // Ne pas retourner 1 !
    return parseInt(id);
};

exports.getAllIngredients = async (req, res) => {
  try {
    const userId = getUserId(req); // On récupère l'ID numérique
    console.log("Récupération des ingrédients pour l'user ID :", userId);

    // On appelle la méthode du modèle Aliment
    const ingredients = await Aliment.findAllByUser(userId);
    
    res.json(ingredients);
  } catch (error) {
    console.error("ERREUR GET ALL INGREDIENTS:", error);
    res.status(500).json({ message: 'Erreur serveur lors de la récupération' });
  }
}


exports.addIngredient = async (req, res) => {
  try {
    const { nom, quantite, unite, type, dateExpiration } = req.body;

    if (!nom || !quantite || !unite || !type) {
      return res.status(400).json({
        message: 'Nom, quantité, unité et type sont obligatoires'
      });
    }

    const userId = parseInt(req.userId);
    const id = await Aliment.create(userId, req.body);

    res.status(201).json({
      message: 'Aliment ajouté avec succès',
      id
    });
  } catch (error) {
    console.error("ADD INGREDIENT ERROR:", error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.updateIngredient = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = getUserId(req);

    if (!userId) return res.status(401).json({ message: 'Non autorisé' });
    const belongsToUser = await Aliment.belongsToUser(id, userId);
    if (!belongsToUser) {
      return res.status(403).json({ message: 'Cet aliment ne vous appartient pas' });
    }


    const updated = await Aliment.update(id, userId, req.body);

    if (updated) {
      res.json({ message: 'Aliment mis à jour avec succès' });
    } else {
      res.status(404).json({ message: 'Aliment non trouvé' });
    }
  } catch (error) {
    console.error("UPDATE INGREDIENT ERROR:", error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.deleteIngredient = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await Aliment.delete(id, req.userId);

    if (deleted) {
      res.json({ message: 'Aliment supprimé avec succès' });
    } else {
      res.status(404).json({ message: 'Aliment non trouvé' });
    }
  } catch (error) {
    console.error("DELETE INGREDIENT ERROR:", error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};