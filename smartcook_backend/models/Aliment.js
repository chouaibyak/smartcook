const db = require('../config/db');

const Aliment = {
  // On utilise une Promise pour pouvoir faire "await Aliment.create"
  create: (data) => {
    return new Promise((resolve, reject) => {
      const query = `INSERT INTO aliment 
        (idInventaire, nom, quantite, unite, type, dateExpiration, calories, proteines, glucides, lipides, allergenes, marque, categorie, imageUrl, statut) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

      // Sécurité : on s'assure que les valeurs numériques ne sont pas indéfinies (NaN)
      const values = [
        data.idInventaire || 1, // Valeur par défaut si non fourni
        data.nom || 'Inconnu',
        data.quantite || 1,
        data.unite || 'pcs',
        data.type || 'autre',
        data.dateExpiration || null,
        data.calories || 0,
        data.proteines || 0,
        data.glucides || 0,
        data.lipides || 0,
        data.allergenes || 'Aucun',
        data.marque || 'Générique',
        data.categorie || 'Inconnu',
        data.imageUrl || '',
        data.statut || 'disponible'
      ];

      db.query(query, values, (err, result) => {
        if (err) return reject(err);
        resolve(result);
      });
    });
  }
};

module.exports = Aliment;