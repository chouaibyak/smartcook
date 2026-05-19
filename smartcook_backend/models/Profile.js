const db = require('../config/db');

const Profile = {

    // UPDATE PROFILE
    updateByUserId: async (userId, profileData) => {

        const {
            taille,
            poids,
            objectif,
            allergies,
            sante,
            diet
        } = profileData;

        const allergiesStr = JSON.stringify(allergies || []);
        const santeStr = JSON.stringify(sante || []);
        const dietStr = JSON.stringify(diet || []);

        const sql = `
            INSERT INTO profilutilisateur
            (
                idUtilisateur,
                taille,
                poids,
                objectifNutritionnel,
                allergies,
                conditionsSante,
                preferencesAlimentaires
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)

            ON DUPLICATE KEY UPDATE
                taille = VALUES(taille),
                poids = VALUES(poids),
                objectifNutritionnel = VALUES(objectifNutritionnel),
                allergies = VALUES(allergies),
                conditionsSante = VALUES(conditionsSante),
                preferencesAlimentaires = VALUES(preferencesAlimentaires)
        `;

        const values = [
            userId,
            taille,
            poids,
            objectif,
            allergiesStr,
            santeStr,
            dietStr
        ];

        return await db.execute(sql, values);
    },

    // GET PROFILE
    getByUserId: async (userId) => {

        const sql = `
            SELECT
                u.id,
                u.nom,
                u.email,

                p.taille,
                p.poids,
                p.objectifNutritionnel,
                p.allergies,
                p.conditionsSante,
                p.preferencesAlimentaires

            FROM utilisateur u

            LEFT JOIN profilutilisateur p
            ON u.id = p.idUtilisateur

            WHERE u.id = ?
        `;

        const [rows] = await db.execute(sql, [userId]);

        return rows[0];
    }
};

module.exports = Profile;