const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
    const { nom, email, password } = req.body;
    try {
        // Vérifier si l'email existe
        const [existing] = await db.execute('SELECT id FROM utilisateur WHERE email = ?', [email]);
        if (existing.length > 0) return res.status(400).json({ message: "Email déjà utilisé" });

        // Hasher le mot de passe
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insérer l'utilisateur
        const [result] = await db.execute(
            'INSERT INTO utilisateur (nom, email, motDePasse) VALUES (?, ?, ?)',
            [nom, email, hashedPassword]
        );

        const userId = result.insertId;

        // Initialiser l'inventaire et la liste de courses automatiquement (UML)
        
        // Générer un token pour que Flutter puisse passer directement au profil
        const token = jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: '1d' });
        
        await db.execute('UPDATE utilisateur SET token = ? WHERE id = ?', [token, userId]);
        
        await db.execute('INSERT INTO inventaire (idUtilisateur) VALUES (?)', [userId]);
        await db.execute('INSERT INTO listecourses (idUtilisateur) VALUES (?)', [userId]);

        await db.execute('INSERT INTO profilutilisateur (idUtilisateur) VALUES (?)', [userId]);
        
        res.status(201).json({ message: "Utilisateur créé", token, userId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.login = async (req, res) => {
    const { email, password } = req.body;
    try {
        const [users] = await db.execute('SELECT * FROM utilisateur WHERE email = ?', [email]);
        if (users.length === 0) return res.status(404).json({ message: "Utilisateur non trouvé" });

        const user = users[0];
        const isMatch = await bcrypt.compare(password, user.motDePasse);
        if (!isMatch) return res.status(400).json({ message: "Mot de passe incorrect" });

        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1d' });
        res.json({ token, user: { id: user.id, nom: user.nom, email: user.email } });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};