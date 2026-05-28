const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ message: 'Pas de token' });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Debug (pratique pour les tests avec Flutter)
        console.log("CONTENU DU TOKEN DÉCODÉ :", decoded); 

        // Double assignation pour satisfaire HEAD et main (Zéro conflit dans les contrôleurs !)
        req.user = { id: decoded.id };
        req.userId = decoded.id;

        next();
    } catch (error) {
        console.log("ERREUR JWT DÉTAILLÉE :", error.message); 
        res.status(401).json({ message: 'Authentication failed (invalid token)' });
    }
};
