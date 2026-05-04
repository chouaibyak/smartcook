const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();

// 1. Middlewares de base
app.use(cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 2. Middleware de Logging (pour voir les requêtes de Flutter dans ta console)
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    if (Object.keys(req.body).length > 0) console.log("BODY:", req.body);
    next();
});

// 3. Routes API
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);

app.get('/', (req, res) => {
    res.send("SmartCook API is running...");
});

// 4. Gestion des erreurs (Middleware final)
app.use((err, req, res, next) => {
    console.error("SERVER ERROR:", err);
    res.status(500).json({
        message: "Internal server error",
        error: err.message
    });
});

// IMPORTANT : On exporte l'app pour server.js
module.exports = app;