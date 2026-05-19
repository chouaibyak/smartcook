const db = require('../config/db');
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
        res.status(500).json({ message: 'Erreur serveur lors de la récupération', error: error.message });
    }
};

// ==========================================
// 2. AJOUT D'UN INGRÉDIENT (Complet + Nutrition)
// ==========================================
const addIngredient = async (req, res) => {
    try {
        const userId = getUserId(req);
        if (!userId) return res.status(401).json({ message: 'Non autorisé' });

        const { nom } = req.body;
        if (!nom) return res.status(400).json({ message: 'Le nom est obligatoire' });

        // On passe directement tout le body au modèle corrigé pour sauvegarder tes champs (barcode, calories, etc.)
        const id = await Aliment.create(userId, req.body);

        res.status(201).json({ message: 'Aliment complet ajouté avec succès', id });
    } catch (error) {
        console.error("ADD INGREDIENT ERROR:", error);
        res.status(500).json({ message: 'Erreur serveur lors de l\'ajout', error: error.message });
    }
};

// ==========================================
// 3. MODIFICATION D'UN INGRÉDIENT
// ==========================================
const updateIngredient = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = getUserId(req);

        if (!userId) return res.status(401).json({ message: 'Non autorisé' });

        const belongsToUser = await Aliment.belongsToUser(id, userId);
        if (!belongsToUser) {
            return res.status(403).json({ message: 'Cet aliment ne vous appartient pas ou n\'existe pas' });
        }

        console.log("UPDATE PARAMS:", { id, userId });

        const updated = await Aliment.update(id, userId, req.body);

        if (updated) {
            res.status(200).json({ message: 'Aliment modifié avec succès' });
        } else {
            res.status(404).json({ message: 'Aliment non trouvé' });
        }
    } catch (error) {
        console.error("UPDATE INGREDIENT ERROR:", error);
        res.status(500).json({ message: 'Erreur serveur lors de la modification', error: error.message });
    }
};

// ==========================================
// 4. SUPPRESSION D'UN INGRÉDIENT
// ==========================================
const deleteIngredient = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = getUserId(req);

        if (!userId) return res.status(401).json({ message: 'Non autorisé' });

        const deleted = await Aliment.delete(id, userId);

        if (deleted) {
            res.status(200).json({ message: 'Aliment supprimé avec succès' });
        } else {
            res.status(404).json({ message: 'Aliment non trouvé' });
        }
    } catch (error) {
        console.error("DELETE INGREDIENT ERROR:", error);
        res.status(500).json({ message: 'Erreur serveur lors de la suppression', error: error.message });
    }
};

// Aliases d'exportation pour assurer une compatibilité totale (HEAD + main)
module.exports = {
    getAllIngredients,
    addIngredient,
    updateIngredient,
    deleteIngredient,
    
    // Gardés en alias pour tes endpoints Flutter actuels
    getInventory: getAllIngredients,
    addItem: addIngredient,
    updateItem: updateIngredient,
    deleteItem: deleteIngredient
};