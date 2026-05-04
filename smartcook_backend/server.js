require('dotenv').config(); // On charge les variables d'environnement ici
const app = require('./app'); // On importe la configuration de l'app

const PORT = process.env.PORT || 3000;

// On lance le serveur
app.listen(PORT, () => {
    console.log("========================================");
    console.log(`Serveur SmartCook lancé sur : http://localhost:${PORT}`);
    console.log(`En attente de requêtes de Flutter...`);
    console.log("========================================");
});