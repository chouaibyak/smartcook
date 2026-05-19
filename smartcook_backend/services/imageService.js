const axios = require('axios');

const translations = {
  ail: 'garlic',
  agneau: 'lamb',
  banane: 'banana',
  beurre: 'butter',
  boeuf: 'beef',
  bœuf: 'beef',
  cannelle: 'cinnamon',
  carotte: 'carrot',
  champignon: 'mushroom',
  citron: 'lemon',
  concombre: 'cucumber',
  crevette: 'shrimp',
  farine: 'flour',
  fraise: 'strawberry',
  fromage: 'cheese',
  jambon: 'ham',
  lait: 'milk',
  oeuf: 'egg',
  oeufs: 'egg',
  oignon: 'onion',
  pain: 'bread',
  pates: 'pasta',
  pâtes: 'pasta',
  poivre: 'pepper',
  pomme: 'apple',
  'pomme de terre': 'potato',
  porc: 'pork',
  poulet: 'chicken',
  riz: 'rice',
  salade: 'lettuce',
  saumon: 'salmon',
  sel: 'salt',
  sucre: 'sugar',
  thon: 'tuna',
  tomate: 'tomato',
  yaourt: 'yogurt',
};

const typeFallbackQueries = {
  vegetables: 'fresh vegetables',
  légumes: 'fresh vegetables',
  fruits: 'fresh fruit',
  fruit: 'fresh fruit',
  meat: 'meat food',
  viande: 'meat food',
  'dairy & eggs': 'milk eggs dairy',
  dairy: 'milk eggs dairy',
  seafood: 'seafood',
  grains: 'rice grains',
  bakery: 'bread bakery',
  frozen: 'frozen vegetables',
  snacks: 'snack food',
  drinks: 'drink beverage',
  spices: 'spices food',
  organic: 'organic fruit',
  'canned food': 'canned food',
  sauces: 'sauce food',
  sweets: 'dessert sweets',
  breakfast: 'breakfast food',
};

function normalize(value) {
  return (value || '')
    .toString()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .trim();
}

function buildQuery(foodName, type) {
  const normalizedName = normalize(foodName);
  const translated = translations[normalizedName] || normalizedName;

  if (translated) {
    return translated;
  }

  return typeFallbackQueries[normalize(type)] || 'fresh food';
}

function scoreHit(hit, query) {
  const tags = normalize(hit.tags);
  const page = normalize(hit.pageURL);
  const queryTokens = normalize(query)
    .split(/\s+/)
    .filter(Boolean);

  let score = 0;

  for (const token of queryTokens) {
    if (tags.split(',').some(tag => normalize(tag) === token)) score += 12;
    if (tags.includes(token)) score += 6;
    if (page.includes(token)) score += 2;
  }

  if (tags.includes('food')) score += 4;
  if (tags.includes('fresh')) score += 2;
  if (hit.imageWidth > hit.imageHeight) score += 1;
  if (hit.likes) score += Math.min(hit.likes / 100, 3);

  return score;
}

exports.getFoodImage = async (foodName, type) => {
  try {
    const API_KEY = process.env.PIXABAY_API_KEY;

    if (!API_KEY) {
      console.error("PIXABAY_API_KEY manquante dans smartcook_backend/.env");
      return null;
    }

    const query = buildQuery(foodName, type);

    const response = await axios.get('https://pixabay.com/api/', {
      params: {
        key: API_KEY,
        q: query,
        image_type: 'photo',
        category: 'food',
        safesearch: true,
        orientation: 'horizontal',
        per_page: 30,
        lang: 'en',
      },
      timeout: 10000,
    });

    const hits = response.data?.hits || [];

    if (hits.length === 0) {
      console.warn(`Aucune image Pixabay pour "${query}"`);
      return null;
    }

    const bestHit = hits
      .map(hit => ({ hit, score: scoreHit(hit, query) }))
      .sort((a, b) => b.score - a.score)[0]?.hit;

    return (
      bestHit?.largeImageURL ||
      bestHit?.webformatURL ||
      bestHit?.previewURL ||
      null
    );

  } catch (error) {
    console.error('Erreur Pixabay:', error.message);
    return null;
  }
};
