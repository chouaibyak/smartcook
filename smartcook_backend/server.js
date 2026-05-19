const path = require('path');
require('dotenv').config({
    path: path.join(__dirname, '.env'),
    quiet: true
}); // Charge smartcook_backend/.env, quel que soit le dossier de lancement
const app = require('./app'); // On importe la configuration de l'app

const PORT = process.env.PORT || 3000;

// On lance le serveur
// On lance le serveur en forçant l'écoute sur 0.0.0.0
app.listen(PORT, '0.0.0.0', () => {
    console.log("========================================");
    console.log(`Serveur SmartCook lancé !`);
    console.log(`Local (PC) : http://localhost:${PORT}`);
    console.log(`Émulateur Android : http://10.0.2.2:${PORT}`);
    console.log("========================================");
});
