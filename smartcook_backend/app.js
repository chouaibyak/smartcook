const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const inventoryRoutes = require('./routes/inventoryRoutes'); 
const alimentRoutes = require('./routes/alimentRoutes');

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
    if (req.body && Object.keys(req.body).length > 0) {
        console.log("BODY:", req.body);
    }
    next();
});

// 3. Routes API
app.use('/api/auth', authRoutes);
app.use('/api/inventory', inventoryRoutes); 
app.use('/api/user', userRoutes);
app.use('/api/aliments', alimentRoutes);

app.get('/', (req, res) => {
    res.send("SmartCook API is running...");
});

// 4. Gestion des erreurs
app.use((err, req, res, next) => {
    console.error("SERVER ERROR:", err);
    res.status(500).json({
        message: "Internal server error",
        error: err.message
    });
});

module.exports = app;