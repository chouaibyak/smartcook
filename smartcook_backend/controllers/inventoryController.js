const Aliment = require('../models/Aliment');

exports.getAllIngredients = async (req, res) => {
  try {
    const ingredients = await Aliment.findAllByUser(req.userId);
    res.json(ingredients);
  } catch (error) {
    console.error("GET INGREDIENTS ERROR:", error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.addIngredient = async (req, res) => {
  try {
    const { nom, quantite, unite, type, dateExpiration } = req.body;

    if (!nom || !quantite || !unite || !type) {
      return res.status(400).json({
        message: 'Nom, quantité, unité et type sont obligatoires'
      });
    }

    const id = await Aliment.create(req.userId, req.body);

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

    const belongsToUser = await Aliment.belongsToUser(id, req.userId);
    if (!belongsToUser) {
      return res.status(404).json({ message: 'Aliment non trouvé' });
    }

    const updated = await Aliment.update(id, req.userId, req.body);

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