const db = require('../config/db');

class Recipe {
    static async ensureIngredientColumns() {
        const [availableColumns] = await db.query("SHOW COLUMNS FROM recette LIKE 'ingredientsDisponibles'");
        if (availableColumns.length === 0) {
            await db.query("ALTER TABLE recette ADD COLUMN ingredientsDisponibles TEXT NULL AFTER nbPersonnes");
        }

        const [missingColumns] = await db.query("SHOW COLUMNS FROM recette LIKE 'ingredientsManquants'");
        if (missingColumns.length === 0) {
            await db.query("ALTER TABLE recette ADD COLUMN ingredientsManquants TEXT NULL AFTER ingredientsDisponibles");
        }
    }

    static async bulkCreate(recipesArray) {
        await this.ensureIngredientColumns();

        const query = `
            INSERT INTO recette (
                idUtilisateur, nom, imageUrl, typeRepas, tempsPreparation,
                difficulte, nbPersonnes, ingredientsDisponibles, ingredientsManquants, etapes,
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
            "SELECT * FROM recette WHERE idUtilisateur = ? ORDER BY scoreCompatibilite DESC, id DESC",
            [userId]
        );
        return rows;
    }
}

module.exports = Recipe;
