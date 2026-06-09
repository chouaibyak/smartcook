const axios = require('axios');

const USDA_API_KEY = process.env.USDA_API_KEY;

exports.getNutrition = async (name) => {
  try {
    const response = await axios.get(
      'https://api.nal.usda.gov/fdc/v1/foods/search',
      {
        params: {
          api_key: USDA_API_KEY,
          query: name,
          pageSize: 10
        },
        timeout: 10000
      }
    );

    const foods = response.data.foods || [];

    if (foods.length === 0) {
      return null;
    }

const food =
  foods.find(f => {
    const desc = (f.description || '').toLowerCase();

    return (
     desc.includes(name.toLowerCase().trim()) &&
      (
        desc.includes('raw') ||
        desc.includes('fresh')
      ) &&
      !desc.includes('dried') &&
      !desc.includes('canned') &&
      !desc.includes('fried') &&
      !desc.includes('with sauce')
    );
  }) ||

  foods.find(f => {
    const desc = (f.description || '').toLowerCase();

    return (
      desc.includes(name.toLowerCase().trim())&&
      !desc.includes('dried')
    );
  }) ||

  foods[0];

    const nutrients = food.foodNutrients || [];

    const getValue = (nutrientName) => {
      const nutrient = nutrients.find(item =>
        item.nutrientName &&
        item.nutrientName.toLowerCase().includes(nutrientName)
      );

      return Number(nutrient?.value || 0);
    };

    return {
      calories: Math.round(getValue('energy')),
      proteines: Number(getValue('protein').toFixed(1)),
      glucides: Number(getValue('carbohydrate').toFixed(1)),
      lipides: Number(getValue('total lipid').toFixed(1))
    };

  } catch (error) {
    console.error('Erreur USDA:', error.message);
    return null;
  }
};