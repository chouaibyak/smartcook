const db = require('../config/db');

exports.updateInitialProfile = async (req, res) => {
    const { taille, poids, objectif, allergies, sante, diet } = req.body;
    const userId = req.userId; // Récupéré via authMiddleware

    try {
        // Sauvegarde dans la table profilutilisateur
        // On utilise ON DUPLICATE KEY car idUtilisateur est la clé primaire
        await db.execute(
            `INSERT INTO profilutilisateur (idUtilisateur, taille, poids, objectifNutritionnel, allergies, conditionsSante, preferencesAlimentaires) 
             VALUES (?, ?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE taille=?, poids=?, objectifNutritionnel=?, allergies=?, conditionsSante=?, preferencesAlimentaires=?`,
            [
                userId, taille, poids, objectif, JSON.stringify(allergies), JSON.stringify(sante), JSON.stringify(diet),
                taille, poids, objectif, JSON.stringify(allergies), JSON.stringify(sante), JSON.stringify(diet)
            ]
        );

        res.status(200).json({ message: "Profil complété avec succès !" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};