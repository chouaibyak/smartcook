const axios = require('axios');

exports.getFoodImage = async (foodName) => {
  try {
    const API_KEY = process.env.PIXABAY_API_KEY;

    if (!API_KEY) {
      console.error("PIXABAY_API_KEY manquante dans .env");
      return null;
    }

    if (!foodName) {
      return null;
    }

    const key = foodName.toLowerCase().trim();

    const translations = {
      sucre: 'sugar',
      thon: 'tuna',
      tomate: 'tomato',
      carotte: 'carrot',
      oignon: 'onion',
      oeuf: 'egg',
      lait: 'milk',
      fromage: 'cheese',
      poulet: 'chicken',
      pomme: 'apple',
      banane: 'banana',
      fraise: 'strawberry',
      riz: 'rice',
      sel: 'salt',
      poivre: 'pepper',
      cannelle: 'cinnamon'
    };

    const fixedImages = {
      fraise: 'https://images.pexels.com/photos/46174/strawberries-berries-fruit-freshness-46174.jpeg',
      strawberry: 'https://images.pexels.com/photos/46174/strawberries-berries-fruit-freshness-46174.jpeg',

      rice: 'https://images.pexels.com/photos/4110251/pexels-photo-4110251.jpeg',
      riz: 'https://images.pexels.com/photos/4110251/pexels-photo-4110251.jpeg',

      tomate: 'https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg',
      tomato: 'https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg',

      carotte: 'https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg',
      carrot: 'https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg',

      sucre: 'https://images.pexels.com/photos/65882/spoon-white-sugar-sweet-65882.jpeg',
      sugar: 'https://images.pexels.com/photos/65882/spoon-white-sugar-sweet-65882.jpeg',

      lait: 'https://images.pexels.com/photos/248412/pexels-photo-248412.jpeg',
      milk: 'https://images.pexels.com/photos/248412/pexels-photo-248412.jpeg',

      oeuf: 'https://images.pexels.com/photos/162712/egg-white-food-protein-162712.jpeg',
      egg: 'https://images.pexels.com/photos/162712/egg-white-food-protein-162712.jpeg',

      sel: 'https://images.pexels.com/photos/66307/salt-white-salt-crystal-66307.jpeg',
      salt: 'https://images.pexels.com/photos/66307/salt-white-salt-crystal-66307.jpeg',

      poivre: 'https://images.pexels.com/photos/606540/pexels-photo-606540.jpeg',
      pepper: 'https://images.pexels.com/photos/606540/pexels-photo-606540.jpeg',

      paprika: 'https://images.pexels.com/photos/4198019/pexels-photo-4198019.jpeg',

      curry: 'https://images.pexels.com/photos/6941026/pexels-photo-6941026.jpeg',

      cannelle: 'https://images.pexels.com/photos/616404/pexels-photo-616404.jpeg',
      cinnamon: 'https://images.pexels.com/photos/616404/pexels-photo-616404.jpeg',
    };

    if (fixedImages[key]) {
      return fixedImages[key];
    }

    const query = translations[key] || key;

    const response = await axios.get('https://pixabay.com/api/', {
      params: {
        key: API_KEY,
        q: `${query} food`,
        image_type: 'photo',
        category: 'food',
        safesearch: true,
        orientation: 'horizontal',
        per_page: 10,
      },
      timeout: 10000,
    });

    if (response.data.hits && response.data.hits.length > 0) {
      const hit = response.data.hits[0];

      return (
        hit.largeImageURL ||
        hit.webformatURL ||
        hit.previewURL ||
        null
      );
    }

    return null;

  } catch (error) {
    console.error('Erreur Pixabay:', error.message);
    return null;
  }
};