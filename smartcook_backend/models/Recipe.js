const db = require('../config/db');

class Recipe {
    static async bulkCreate(recipesArray) {
        const query = `
            INSERT INTO recette (
                idUtilisateur, nom, imageUrl, typeRepas, tempsPreparation,
                difficulte, nbPersonnes, etapes,
                calories, proteines, glucides, lipides,
                benefices, conseilsSante, scoreCompatibilite
            ) VALUES ?
        `;
        return await db.query(query, [recipesArray]);
    }

    static async deleteAllByUserId(userId) {
        return await db.query("DELETE FROM recette WHERE idUtilisateur = ?", [userId]);
    }

    static async findAllByUserId(userId) {
        const [rows] = await db.query(
            "SELECT * FROM recette WHERE idUtilisateur = ? ORDER BY id DESC",
            [userId]
        );
        return rows;
    }
}

module.exports = Recipe;