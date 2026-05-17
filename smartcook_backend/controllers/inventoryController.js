const Aliment = require('../models/Aliment');


// NOUVEAU : fonction centralisée
// pour récupérer l'ID utilisateur depuis le JWT
const getUserId = (req) => {

  // Cherche l'userId soit dans :
  // req.userId
  // ou req.user.id
  const id = req.userId || (req.user ? req.user.id : null);

  //  Sécurité :
  // si aucun utilisateur connecté
  // on retourne null
  // et NON PAS 1 par défaut
  if (!id) return null;

  // Conversion en entier
  return parseInt(id);
};

exports.getAllIngredients = async (req, res) => {
  try {

    // ✅ NOUVEAU :
    // récupération sécurisée du userId
    const userId = getUserId(req);

    console.log(
      "Récupération des ingrédients pour l'user ID :",
      userId
    );

    // Recherche uniquement
    // des aliments appartenant à cet utilisateur
    const ingredients = await Aliment.findAllByUser(userId);

    res.json(ingredients);

  } catch (error) {
    console.error("ERREUR GET ALL INGREDIENTS:", error);

    res.status(500).json({
      message: 'Erreur serveur lors de la récupération'
    });
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

    //  NOUVEAU :
    // conversion du userId en nombre entier
    const userId = parseInt(req.userId);

    //  Création aliment lié à l'utilisateur connecté
    const id = await Aliment.create(userId, req.body);

    res.status(201).json({
      message: 'Aliment ajouté avec succès',
      id
    });

  } catch (error) {
    console.error("ADD INGREDIENT ERROR:", error);

    res.status(500).json({
      message: 'Erreur serveur'
    });
  }
};

exports.updateIngredient = async (req, res) => {
  try {
    const { id } = req.params;

    // NOUVEAU :
    // récupération sécurisée du userId
    const userId = getUserId(req);

    //  NOUVEAU :
    // vérifie si utilisateur connecté
    if (!userId) {
      return res.status(401).json({
        message: 'Non autorisé'
      });
    }

    //  Vérifie que l'aliment
    // appartient bien à cet utilisateur
    const belongsToUser = await Aliment.belongsToUser(id, userId);

    // NOUVEAU :
    // message plus précis et sécurisé
    if (!belongsToUser) {
      return res.status(403).json({
        message: 'Cet aliment ne vous appartient pas'
      });
    }

    console.log("UPDATE BODY:", req.body);
    console.log("UPDATE PARAMS:", { id, userId });

    // Mise à jour de l'aliment
    const updated = await Aliment.update(id, userId, req.body);

    if (updated) {
      res.json({
        message: 'Aliment mis à jour avec succès'
      });
    } else {
      res.status(404).json({
        message: 'Aliment non trouvé'
      });
    }

  } catch (error) {
    console.error("UPDATE INGREDIENT ERROR:", error);

    res.status(500).json({
      message: 'Erreur serveur'
    });
  }
};

exports.deleteIngredient = async (req, res) => {
  try {
    const { id } = req.params;

    // Suppression uniquement
    // des aliments appartenant à l'utilisateur connecté
    const deleted = await Aliment.delete(id, req.userId);

    if (deleted) {
      res.json({
        message: 'Aliment supprimé avec succès'
      });
    } else {
      res.status(404).json({
        message: 'Aliment non trouvé'
      });
    }

  } catch (error) {
    console.error("DELETE INGREDIENT ERROR:", error);

    res.status(500).json({
      message: 'Erreur serveur'
    });
  }
};