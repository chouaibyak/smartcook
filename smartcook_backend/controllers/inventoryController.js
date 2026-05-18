const db = require('../config/db');

// 1. Récupérer tous les aliments de l'inventaire avec tous leurs attributs
const getInventory = async (req, res) => {
    try {
        const userId = req.user.id;

        // On cherche l'inventaire lié à l'utilisateur
        const [inventoryRows] = await db.query('SELECT id FROM inventaire WHERE idUtilisateur = ?', [userId]);

        if (inventoryRows.length === 0) {
            return res.status(200).json([]);
        }

        const inventoryId = inventoryRows[0].id;

        // On récupère tous les aliments rattachés à cet inventaire (inclut automatiquement toutes les colonnes)
        const [aliments] = await db.query('SELECT * FROM aliment WHERE idInventaire = ?', [inventoryId]);
        
        res.status(200).json(aliments);
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur lors de la récupération', error: error.message });
    }
};

// 2. Ajouter un aliment complet (avec valeurs nutritionnelles et détails)
const addItem = async (req, res) => {
    try {
        const userId = req.user.id;
        
        // Extraction de TOUS les attributs disponibles dans la table aliment
        const { 
            nom, 
            quantite, 
            unite, 
            dateExpiration, 
            barcode,
            type,
            calories,
            proteines,
            glucides,
            lipides,
            allergenes,
            marque,
            categorie,
            imageUrl
        } = req.body;

        if (!nom) return res.status(400).json({ message: 'Le nom est obligatoire' });

        // Trouver ou créer l'inventaire de l'utilisateur connecté
        const [inventoryRows] = await db.query('SELECT id FROM inventaire WHERE idUtilisateur = ?', [userId]);
        
        let inventoryId;
        if (inventoryRows.length === 0) {
            const [newInventory] = await db.query('INSERT INTO inventaire (idUtilisateur) VALUES (?)', [userId]);
            inventoryId = newInventory.insertId;
        } else {
            inventoryId = inventoryRows[0].id;
        }

        // Insertion complète de l'aliment dans la base de données
        const [result] = await db.query(
            `INSERT INTO aliment (
                idInventaire, nom, quantite, unite, dateExpiration, barcode, statut,
                type, calories, proteines, glucides, lipides, allergenes, marque, categorie, imageUrl
             ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, 
            [
                inventoryId, 
                nom, 
                quantite || 1.0, 
                unite || 'pcs', 
                dateExpiration || null, 
                barcode || null, 
                'disponible',
                type || null,
                calories || null,
                proteines || null,
                glucides || null,
                lipides || null,
                allergenes || null,
                marque || null,
                categorie || null,
                imageUrl || null
            ]
        );

        res.status(201).json({ message: 'Aliment complet ajouté avec succès', id: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur lors de l\'ajout', error: error.message });
    }
};

// 3. Modifier un aliment avec toutes ses caractéristiques
const updateItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params; // ID de l'aliment à modifier
        
        const { 
            nom, 
            quantite, 
            unite, 
            dateExpiration, 
            barcode, 
            statut,
            type,
            calories,
            proteines,
            glucides,
            lipides,
            allergenes,
            marque,
            categorie,
            imageUrl 
        } = req.body;

        // Sécurité : Vérifier que cet aliment appartient bien à l'inventaire de l'utilisateur connecté
        const [check] = await db.query(
            `SELECT a.id FROM aliment a 
             JOIN inventaire i ON a.idInventaire = i.id 
             WHERE a.id = ? AND i.idUtilisateur = ?`, 
            [id, userId]
        );

        if (check.length === 0) {
            return res.status(403).json({ message: 'Action non autorisée ou aliment introuvable' });
        }

        // Mise à jour de l'ensemble des champs de l'aliment
        await db.query(
            `UPDATE aliment 
             SET nom = ?, quantite = ?, unite = ?, dateExpiration = ?, barcode = ?, statut = ?,
                 type = ?, calories = ?, proteines = ?, glucides = ?, lipides = ?, allergenes = ?, 
                 marque = ?, categorie = ?, imageUrl = ?
             WHERE id = ?`, 
            [
                nom, 
                quantite, 
                unite, 
                dateExpiration, 
                barcode, 
                statut || 'disponible',
                type,
                calories,
                proteines,
                glucides,
                lipides,
                allergenes,
                marque,
                categorie,
                imageUrl,
                id
            ]
        );

        res.status(200).json({ message: 'Aliment modifié avec succès' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur lors de la modification', error: error.message });
    }
};

// 4. Supprimer un aliment
const deleteItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;

        // Sécurité : Vérifier l'appartenance de l'aliment
        const [check] = await db.query(
            `SELECT a.id FROM aliment a 
             JOIN inventaire i ON a.idInventaire = i.id 
             WHERE a.id = ? AND i.idUtilisateur = ?`, 
            [id, userId]
        );

        if (check.length === 0) {
            return res.status(403).json({ message: 'Action non autorisée ou aliment introuvable' });
        }

        await db.query('DELETE FROM aliment WHERE id = ?', [id]);

        res.status(200).json({ message: 'Aliment supprimé avec succès' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur lors de la suppression', error: error.message });
    }
};

module.exports = { getInventory, addItem, updateItem, deleteItem };