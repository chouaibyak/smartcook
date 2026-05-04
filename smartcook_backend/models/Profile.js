const db = require('../config/db');

const Profile = {
    // Met à jour ou crée le profil utilisateur
    updateByUserId: async (userId, profileData) => {
        const { taille, poids, objectif, allergies, sante, diet } = profileData;

        // Transformation des tableaux en chaînes JSON pour MySQL
        const allergiesStr = JSON.stringify(allergies || []);
        const santeStr = JSON.stringify(sante || []);
        const dietStr = JSON.stringify(diet || []);

        const sql = `
            INSERT INTO profilutilisateur 
            (idUtilisateur, taille, poids, objectifNutritionnel, allergies, conditionsSante, preferencesAlimentaires) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE 
                taille = VALUES(taille), 
                poids = VALUES(poids), 
                objectifNutritionnel = VALUES(objectifNutritionnel), 
                allergies = VALUES(allergies), 
                conditionsSante = VALUES(conditionsSante), 
                preferencesAlimentaires = VALUES(preferencesAlimentaires)
        `;

        const values = [userId, taille, poids, objectif, allergiesStr, santeStr, dietStr];

        return await db.execute(sql, values);
    },

    // Optionnel : Récupérer le profil (utile pour plus tard)
    getByUserId: async (userId) => {
        const [rows] = await db.execute('SELECT * FROM profilutilisateur WHERE idUtilisateur = ?', [userId]);
        return rows[0];
    }
};

module.exports = Profile;