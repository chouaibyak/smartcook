const express = require('express');
const cors = require('cors');
const path = require('path');

// Import de toutes les routes (Fusion HEAD + main)
const authRoutes      = require('./routes/authRoutes');
const userRoutes      = require('./routes/userRoutes');
const inventoryRoutes = require('./routes/inventoryRoutes');
const recipeRoutes    = require('./routes/recipeRoutes');
const shoppingRoutes  = require('./routes/shoppingRoutes');
const chatRoutes      = require('./routes/chatRoutes');
const alimentRoutes   = require('./routes/alimentRoutes'); // Ajouté par l'équipeconst recipeRoutes = require('./routes/recipeRoutes');

const app = express();

// 1. Middlewares de base
app.use(cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/recipe-images', express.static(path.join(__dirname, 'public', 'recipe-images')));
// 2. Middleware de Logging (pour voir les requêtes de Flutter dans ta console)
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    if (req.body && Object.keys(req.body).length > 0) {
        console.log("BODY:", req.body);
    }
    next();
});

// 3. Routes API (Fusion complète de tous les endpoints)
app.use('/api/auth',      authRoutes);
app.use('/api/user',      userRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/recipes',   recipeRoutes);
app.use('/api/shopping',  shoppingRoutes);
app.use('/api/chat',      chatRoutes);
app.use('/api/aliments',  alimentRoutes); // Ajouté par l'équipe

// 4. Route de test
app.get('/', (req, res) => {
    res.send("SmartCook API is running...");
});

// 5. Gestion globale des erreurs
app.use((err, req, res, next) => {
    console.error("SERVER ERROR:", err);
    res.status(500).json({
        message: "Internal server error",
        error: err.message
    });
});

module.exports = app;
