const Profile = require('../models/Profile');

exports.updateInitialProfile = async (req, res) => {
    // req.userId est injecté par ton authMiddleware (le vérificateur de token)
    const userId = req.userId; 
    
    try {
        // On passe les données du corps de la requête au modèle
        await Profile.updateByUserId(userId, req.body);

        res.status(200).json({ 
            success: true,
            message: "Profil complété avec succès !" 
        });
    } catch (error) {
        console.error("Update Profile Error:", error);
        res.status(500).json({ 
            success: false,
            error: "Erreur lors de la mise à jour du profil" 
        });
    }
};