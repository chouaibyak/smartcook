const db = require('../config/db');

const User = {
    // Trouver un utilisateur par son email
    findByEmail: async (email) => {
        const [rows] = await db.execute('SELECT * FROM utilisateur WHERE email = ?', [email]);
        return rows[0];
    },

    // Insérer un nouvel utilisateur
    create: async (nom, email, hashedPassword) => {
        const [result] = await db.execute(
            'INSERT INTO utilisateur (nom, email, motDePasse) VALUES (?, ?, ?)',
            [nom, email, hashedPassword]
        );
        return result.insertId; // Retourne l'ID généré
    },

    // Mettre à jour le token en base de données
    updateToken: async (userId, token) => {
        return await db.execute('UPDATE utilisateur SET token = ? WHERE id = ?', [token, userId]);
    },

    // Initialiser les tables liées (Inventaire, Liste, Profil) - Logique UML
    initializeAccount: async (userId) => {
        await db.execute('INSERT INTO inventaire (idUtilisateur) VALUES (?)', [userId]);
        await db.execute('INSERT INTO listecourses (idUtilisateur) VALUES (?)', [userId]);
        await db.execute('INSERT INTO profilutilisateur (idUtilisateur) VALUES (?)', [userId]);
    }
};

module.exports = User;