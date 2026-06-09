const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader) {
            return res.status(401).json({ message: 'Pas de token' });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        req.userId = decoded.id;
        req.user = { id: decoded.id };

        next();
    } catch (error) {
        console.log('ERREUR JWT:', error.message);
        res.status(401).json({ message: 'Authentification echouee (Token invalide)' });
    }
};
