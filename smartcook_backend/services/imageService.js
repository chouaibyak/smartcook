const axios = require('axios');

const API_KEY = process.env.PIXABAY_API_KEY;

exports.getFoodImage = async (foodName) => {
  try {

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
      banane: 'banana'
    };

    const query =
      translations[foodName.toLowerCase().trim()] || foodName;

const key = foodName.toLowerCase().trim();

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
};

if (fixedImages[key]) {
  return fixedImages[key];
}


    const response = await axios.get(
      'https://pixabay.com/api/',
      {
       params: {
  key: API_KEY,
  q: `${query} isolated food`,
  image_type: 'photo',
  category: 'food',
  safesearch: true,
  orientation: 'horizontal',
  per_page: 10,
},
      }
    );

    if (
      response.data.hits &&
      response.data.hits.length > 0
    ) {
     return response.data.hits[2]?.webformatURL ||
       response.data.hits[1]?.webformatURL ||
       response.data.hits[0]?.webformatURL;
    }

    return null;

  } catch (error) {
    console.error('Erreur Pixabay:', error.message);
    return null;
  }
};