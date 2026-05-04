const User = require('../models/User'); // On importe le modèle
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// INSCRIPTION
exports.register = async (req, res) => {
    const { nom, email, password } = req.body;
    try {
        // 1. Vérifier si l'utilisateur existe déjà via le modèle
        const existingUser = await User.findByEmail(email);
        if (existingUser) {
            return res.status(400).json({ message: "Email déjà utilisé" });
        }

        // 2. Sécurité : Hasher le mot de passe
        const hashedPassword = await bcrypt.hash(password, 10);

        // 3. Créer l'utilisateur via le modèle
        const userId = await User.create(nom, email, hashedPassword);

        // 4. Initialiser l'environnement utilisateur (Inventaire/Liste/Profil)
        await User.initializeAccount(userId);

        // 5. Générer le Token JWT
        const token = jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: '1d' });
        
        // 6. Sauvegarder le token en BDD via le modèle
        await User.updateToken(userId, token);

        // 7. Réponse (Formatée pour ton UserModel.dart)
        res.status(201).json({
            message: "Utilisateur créé avec succès",
            token: token,
            user: { id: userId, nom, email }
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// CONNEXION
exports.login = async (req, res) => {
    const { email, password } = req.body;
    try {
        // 1. Chercher l'utilisateur via le modèle
        const user = await User.findByEmail(email);
        if (!user) {
            return res.status(404).json({ message: "Utilisateur non trouvé" });
        }

        // 2. Vérifier le mot de passe
        const isMatch = await bcrypt.compare(password, user.motDePasse);
        if (!isMatch) {
            return res.status(400).json({ message: "Mot de passe incorrect" });
        }

        // 3. Générer un nouveau Token
        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1d' });
        await User.updateToken(user.id, token);

        // 4. Réponse envoyée à Flutter (Correspond à ton UserModel Dart)
        res.json({
            token: token,
            user: {
                id: user.id,
                nom: user.nom,
                email: user.email
            }
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};