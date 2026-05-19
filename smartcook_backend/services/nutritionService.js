const axios = require('axios');
const imageService = require('./imageService');

exports.analyzeIngredient = async (name, type) => {
  try {
    const url = `https://world.openfoodfacts.org/cgi/search.pl`;

    const response = await axios.get(url, {
      params: {
        search_terms: name,
        search_simple: 1,
        action: 'process',
        json: 1,
        page_size: 1,
        fields: 'product_name,nutriments,categories,brands,image_front_url,allergens,allergens_tags'
      },
      timeout: 15000,
      headers: {
        'User-Agent': 'SmartCookApp - Version 1.0 - (Contact: ton-email@gmail.com)'
      }
    });

    const image = await imageService.getFoodImage(name, type);

    const naturalTypes = [
      'Fruits',
      'Vegetables',
      'Meat',
      'Seafood',
      'Spices',
      'Grains'
    ];

    const isNaturalType = naturalTypes.includes(type);

    if (response.data && response.data.products && response.data.products.length > 0) {
      const product = response.data.products[0];
      const nutriments = product.nutriments || {};

      const brandText = (product.brands || '').toLowerCase();
      const inputText = name.toLowerCase().trim();

      const brandWords = brandText
        .split(',')
        .map(b => b.trim())
        .filter(b => b.length > 0);

      const isBrandProduct = brandWords.some(brand =>
        inputText.includes(brand) || brand.includes(inputText)
      );

      return {
      allergenes:
  product.allergens ||
  product.allergens_tags?.join(', ') ||
  "Non renseigné",
calories: Math.round(nutriments['energy-kcal_100g'] || 0),
proteines: Number((nutriments.proteins_100g || 0).toFixed(1)),
glucides: Number((nutriments.carbohydrates_100g || 0).toFixed(1)),
lipides: Number((nutriments.fat_100g || 0).toFixed(1)),
        categorie: isNaturalType
          ? type
          : product.categories
            ? product.categories.split(',')[0]
            : "Inconnu",

        marque: isNaturalType
          ? "Inconnu"
          : product.brands
            ? product.brands.split(',')[0]
            : "Inconnu",

        imageUrl: isNaturalType
          ? image || ""
          : isBrandProduct
            ? product.image_front_url || image || ""
            : image || ""
      };
    }

    return {
      calories: 0,
      proteines: 0,
      glucides: 0,
      lipides: 0,
      allergenes: "Non renseigné",
      categorie: type || "Inconnu",
      marque: "Inconnu",
      imageUrl: image || ""
    };

  } catch (error) {
    console.error("Erreur OpenFoodFacts:", error.message);

    const image = await imageService.getFoodImage(name, type);

    return {
      calories: 0,
      proteines: 0,
      glucides: 0,
      lipides: 0,
      allergenes: "Non renseigné",
      categorie: type || "Inconnu",
      marque: "Inconnu",
      imageUrl: image || ""
    };
  }
};
