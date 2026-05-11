const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) return res.status(401).json({ message: 'Pas de header' });

        const token = authHeader.split(' ')[1];

        // --- AJOUTE CE LOG POUR VÉRIFIER LE SECRET ---
        console.log("Secret utilisé :", process.env.JWT_SECRET); 

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        console.log("CONTENU DU TOKEN DÉCODÉ :", decoded); 

        req.userId = decoded.id;
        next();
    } catch (error) {
        // --- CE LOG VA DIRE EXACTEMENT LE PROBLÈME ---
        console.log("ERREUR JWT DÉTAILLÉE :", error.message); 
        res.status(401).json({ message: 'Authentification échouée (Token invalide)' });
    }
};