const axios = require('axios');

exports.analyzeIngredient = async (name) => {
  try {
    const url = `https://world.openfoodfacts.org/cgi/search.pl`;

    const response = await axios.get(url, {
      params: {
        search_terms: name,
        search_simple: 1,
        action: 'process',
        json: 1,
        page_size: 1,
        // CRUCIAL : On ne demande que le strict nécessaire pour éviter le 503
        fields: 'product_name,nutriments,categories,brands,image_front_url'
      },
      timeout: 15000,
      headers: { 
        'User-Agent': 'SmartCookApp - Version 1.0 - (Contact: ton-email@gmail.com)' 
      }
    });

    if (response.data && response.data.products && response.data.products.length > 0) {
      const product = response.data.products[0];
      const nutriments = product.nutriments || {};

      return {
        calories: Math.round(nutriments['energy-kcal_100g'] || 0),
        proteines: nutriments.proteins_100g || 0,
        glucides: nutriments.carbohydrates_100g || 0,
        lipides: nutriments.fat_100g || 0,
        categorie: product.categories ? product.categories.split(',')[0] : "Inconnu",
        marque: product.brands ? product.brands.split(',')[0] : "Inconnu",
        imageUrl: product.image_front_url || ""
      };
    }

    return { calories: 0, proteines: 0, glucides: 0, lipides: 0, categorie: "Inconnu", marque: "Inconnu", imageUrl: "" };

  } catch (error) {
    if (error.response && error.response.status === 503) {
      console.error("OFF est saturé (503). Trop de requêtes ou maintenance.");
      // Optionnel : renvoyer un objet vide au lieu de faire crasher l'app
      return { error: "Service indisponible" };
    }
    console.error("Erreur API:", error.message);
    throw error;
  }
};