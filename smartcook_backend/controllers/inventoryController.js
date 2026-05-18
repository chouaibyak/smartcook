const db = require('../config/db');

// 1. Récupérer tous les aliments de l'inventaire de l'utilisateur connecté
const getInventory = async (req, res) => {
    try {
        const userId = req.user.id;

        // On cherche d'abord l'inventaire lié à l'utilisateur (idUtilisateur)
        const [inventoryRows] = await db.query('SELECT id FROM inventaire WHERE idUtilisateur = ?', [userId]);

        if (inventoryRows.length === 0) {
            // Si l'utilisateur n'a pas encore d'inventaire, on renvoie une liste vide
            return res.status(200).json([]);
        }

        const inventoryId = inventoryRows[0].id;

        // On récupère tous les aliments rattachés à cet inventaire
        const [aliments] = await db.query('SELECT * FROM aliment WHERE idInventaire = ?', [inventoryId]);
        
        res.status(200).json(aliments);
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur lors de la récupération', error: error.message });
    }
};

// 2. Ajouter un aliment dans la table `aliment` rattaché à l'inventaire de l'utilisateur
const addItem = async (req, res) => {
    try {
        const userId = req.user.id;
        // On récupère les champs envoyés par Flutter (attention aux noms exacts de ton SQL)
        const { nom, quantite, unite, dateExpiration, barcode } = req.body;

        if (!nom) return res.status(400).json({ message: 'Le nom est obligatoire' });

        // Étape A : Trouver ou Créer l'idInventaire de l'utilisateur connecté
        const [inventoryRows] = await db.query('SELECT id FROM inventaire WHERE idUtilisateur = ?', [userId]);
        
        let inventoryId;
        if (inventoryRows.length === 0) {
            const [newInventory] = await db.query('INSERT INTO inventaire (idUtilisateur) VALUES (?)', [userId]);
            inventoryId = newInventory.insertId;
        } else {
            inventoryId = inventoryRows[0].id;
        }

        // Étape B : Insérer l'aliment rattaché à cet inventaire
        const [result] = await db.query(
            `INSERT INTO aliment (idInventaire, nom, quantite, unite, dateExpiration, barcode, statut) 
             VALUES (?, ?, ?, ?, ?, ?, ?)`, 
            [
                inventoryId, 
                nom, 
                quantite || 1.0, 
                unite || 'pcs', 
                dateExpiration || null, 
                barcode || null, 
                'disponible'
            ]
        );

        res.status(201).json({ message: 'Aliment ajouté avec succès', id: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur lors de l\'ajout', error: error.message });
    }
};

// 3. Modifier un aliment
const updateItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params; // ID de l'aliment à modifier
        const { nom, quantite, unite, dateExpiration, barcode, statut } = req.body;

        // Sécurité : On vérifie que cet aliment appartient bien à l'inventaire de l'utilisateur connecté
        const [check] = await db.query(
            `SELECT a.id FROM aliment a 
             JOIN inventaire i ON a.idInventaire = i.id 
             WHERE a.id = ? AND i.idUtilisateur = ?`, 
            [id, userId]
        );

        if (check.length === 0) {
            return res.status(403).json({ message: 'Action non autorisée ou aliment introuvable' });
        }

        // Mise à jour de l'aliment
        await db.query(
            `UPDATE aliment 
             SET nom = ?, quantite = ?, unite = ?, dateExpiration = ?, barcode = ?, statut = ? 
             WHERE id = ?`, 
            [nom, quantite, unite, dateExpiration, barcode, statut || 'disponible', id]
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
        const { id } = req.params; // ID de l'aliment

        // Sécurité : On vérifie que cet aliment appartient bien à l'inventaire de l'utilisateur connecté
        const [check] = await db.query(
            `SELECT a.id FROM aliment a 
             JOIN inventaire i ON a.idInventaire = i.id 
             WHERE a.id = ? AND i.idUtilisateur = ?`, 
            [id, userId]
        );

        if (check.length === 0) {
            return res.status(403).json({ message: 'Action non autorisée ou aliment introuvable' });
        }

        // Suppression
        await db.query('DELETE FROM aliment WHERE id = ?', [id]);

        res.status(200).json({ message: 'Aliment supprimé avec succès' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur lors de la suppression', error: error.message });
    }
};

module.exports = { getInventory, addItem, updateItem, deleteItem };