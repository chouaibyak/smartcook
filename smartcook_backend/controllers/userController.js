const Profile = require('../models/Profile');

exports.updateInitialProfile = async (req, res) => {
    const userId = req.userId;

    try {
        await Profile.updateByUserId(userId, req.body);

        res.status(200).json({
            success: true,
            message: "Profile completed successfully!"
        });

    } catch (error) {
        console.error("Update Profile Error:", error);

        res.status(500).json({
            success: false,
            error: "Error while updating profile"
        });
    }
};

exports.getProfile = async (req, res) => {
    const userId = req.userId;

    try {
        const profile = await Profile.getByUserId(userId);
        res.status(200).json(profile || {});
    } catch (error) {
        console.error("Get Profile Error:", error);
        res.status(500).json({
            success: false,
            error: "Error while loading profile"
        });
    }
};
