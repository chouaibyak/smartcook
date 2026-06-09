const axios = require('axios');

const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions';
const DEFAULT_MODEL = 'llama-3.1-8b-instant';

const askGroq = async ({ message, profile, ingredients }) => {
  if (!process.env.GROQ_API_KEY) {
    throw new Error('GROQ_API_KEY is missing');
  }

  const model = process.env.GROQ_MODEL || DEFAULT_MODEL;

  const systemPrompt = `
You are Chef AI, the SmartCook assistant.
You answer questions about cooking, recipes, nutrition, user food profile, inventory, missing ingredients, and shopping lists.
Use the user's profile and inventory when available.
If the user has allergies or health constraints, respect them.
Give practical, clear answers in the same language as the user.
Do not invent medical diagnoses. For serious medical questions, advise consulting a professional.
Keep responses concise unless the user asks for details.
`;

  const context = {
    profile: sanitizeProfile(profile),
    ingredients: sanitizeIngredients(ingredients),
  };

  const response = await axios.post(
    GROQ_API_URL,
    {
      model,
      messages: [
        { role: 'system', content: systemPrompt.trim() },
        {
          role: 'user',
          content: JSON.stringify({
            userMessage: message,
            smartCookContext: context,
          }),
        },
      ],
      temperature: 0.6,
      max_tokens: 700,
    },
    {
      headers: {
        Authorization: `Bearer ${process.env.GROQ_API_KEY}`,
        'Content-Type': 'application/json',
      },
      timeout: 20000,
    }
  );

  return response.data?.choices?.[0]?.message?.content?.trim();
};

const sanitizeProfile = (profile) => {
  if (!profile) return null;

  return {
    nom: profile.nom,
    taille: profile.taille,
    poids: profile.poids,
    objectifNutritionnel: profile.objectifNutritionnel,
    allergies: parseJsonField(profile.allergies),
    conditionsSante: parseJsonField(profile.conditionsSante),
    preferencesAlimentaires: parseJsonField(profile.preferencesAlimentaires),
  };
};

const sanitizeIngredients = (ingredients = []) => {
  return ingredients.slice(0, 40).map((item) => ({
    nom: item.nom,
    quantite: item.quantite,
    unite: item.unite,
    type: item.type,
    dateExpiration: item.dateExpiration,
    calories: item.calories,
    proteines: item.proteines,
    glucides: item.glucides,
    lipides: item.lipides,
    allergenes: item.allergenes,
    statut: item.statut,
  }));
};

const parseJsonField = (value) => {
  if (!value) return [];
  if (Array.isArray(value)) return value;

  try {
    return JSON.parse(value);
  } catch (_) {
    return value;
  }
};

module.exports = {
  askGroq,
};
