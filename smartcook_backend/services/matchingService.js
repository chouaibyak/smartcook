const normalizeText = (value) => {
    return String(value || "")
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/œ/g, "oe")
        .replace(/[^a-z0-9\s]/g, " ")
        .replace(/\s+/g, " ")
        .trim();
};

const parseList = (value) => {
    if (!value) return [];

    if (Array.isArray(value)) {
        return value.map(normalizeText).filter(Boolean);
    }

    const text = String(value).trim();

    try {
        const parsed = JSON.parse(text);
        if (Array.isArray(parsed)) {
            return parsed.map(normalizeText).filter(Boolean);
        }
    } catch (_) {
        // Old profiles can be stored as comma-separated text.
    }

    return text
        .split(",")
        .map(normalizeText)
        .filter(Boolean);
};

const toNumber = (value) => {
    const number = Number(value);
    return Number.isFinite(number) ? number : 0;
};

const clamp = (value, min = 0, max = 100) => {
    return Math.max(min, Math.min(max, value));
};

const textIncludesAny = (text, words) => {
    return words.some(word => text.includes(normalizeText(word)));
};

const containsPositiveMention = (text, term) => {
    const words = normalizeText(text).split(" ").filter(Boolean);
    const target = normalizeText(term);

    for (let index = 0; index < words.length; index++) {
        if (words[index] !== target) continue;

        const previous = words[index - 1] || "";
        const twoPrevious = words[index - 2] || "";
        const recentWords = words.slice(Math.max(0, index - 4), index);
        const next = words[index + 1] || "";

        if (previous === "sans" || previous === "without" || previous === "no") {
            continue;
        }

        if (twoPrevious === "sans" && previous === "de") {
            continue;
        }

        if (recentWords.includes("sans") && (recentWords.includes("et") || recentWords.includes("ni") || recentWords.includes("de"))) {
            continue;
        }

        if (next === "free") {
            continue;
        }

        return true;
    }

    return false;
};

const getRecipeText = (recipe) => {
    return normalizeText([
        recipe.nom,
        recipe.typeRepas,
        recipe.etapes,
        recipe.benefices,
        recipe.conseilsSante,
        recipe.imagePrompt
    ].join(" "));
};

const getRecipeCookingText = (recipe) => {
    return normalizeText([
        recipe.nom,
        recipe.typeRepas,
        recipe.etapes
    ].join(" "));
};

const calculateRangeScore = (value, idealMin, idealMax, hardMin, hardMax) => {
    if (value <= 0) return 40;
    if (value >= idealMin && value <= idealMax) return 100;
    if (value < hardMin || value > hardMax) return 0;

    if (value < idealMin) {
        return ((value - hardMin) / (idealMin - hardMin)) * 100;
    }

    return ((hardMax - value) / (hardMax - idealMax)) * 100;
};

const getNutritionTargets = (profile) => {
    const goal = normalizeText(profile?.objectifNutritionnel);
    const conditions = parseList(profile?.conditionsSante).join(" ");
    const heightCm = toNumber(profile?.taille);
    const weightKg = toNumber(profile?.poids);
    const heightM = heightCm > 0 ? heightCm / 100 : 0;
    const bmi = heightM > 0 ? weightKg / (heightM * heightM) : 0;

    const targets = {
        calories: { idealMin: 450, idealMax: 750, hardMin: 250, hardMax: 950 },
        protein: { idealMin: 20, idealMax: 45, hardMin: 5, hardMax: 70 },
        fat: { idealMin: 10, idealMax: 28, hardMin: 2, hardMax: 45 },
        carbs: { idealMin: 35, idealMax: 85, hardMin: 10, hardMax: 120 }
    };

    if (goal.includes("perte") || goal.includes("minceur") || goal.includes("maigrir") || bmi >= 30) {
        targets.calories = { idealMin: 350, idealMax: 600, hardMin: 200, hardMax: 800 };
        targets.protein = { idealMin: 25, idealMax: 55, hardMin: 10, hardMax: 75 };
        targets.fat = { idealMin: 6, idealMax: 22, hardMin: 0, hardMax: 35 };
        targets.carbs = { idealMin: 20, idealMax: 65, hardMin: 5, hardMax: 95 };
    }

    if (goal.includes("prise") || goal.includes("muscle") || goal.includes("masse")) {
        targets.calories = { idealMin: 650, idealMax: 950, hardMin: 400, hardMax: 1200 };
        targets.protein = { idealMin: 30, idealMax: 65, hardMin: 15, hardMax: 90 };
        targets.fat = { idealMin: 12, idealMax: 35, hardMin: 4, hardMax: 55 };
        targets.carbs = { idealMin: 55, idealMax: 120, hardMin: 20, hardMax: 160 };
    }

    if (conditions.includes("diabete") || conditions.includes("diabetes")) {
        targets.carbs = { idealMin: 20, idealMax: 55, hardMin: 5, hardMax: 85 };
        targets.calories.hardMax = Math.min(targets.calories.hardMax, 850);
    }

    if (conditions.includes("cholesterol") || conditions.includes("cardiaque") || conditions.includes("hypertension")) {
        targets.fat = { idealMin: 5, idealMax: 22, hardMin: 0, hardMax: 35 };
    }

    return targets;
};

const calculateSafetyScore = (recipeText, profile, ingredients) => {
    let score = 100;
    const allergies = parseList(profile?.allergies);
    const usedIngredients = ingredients.filter(i => {
        const name = normalizeText(i.nom);
        return name && recipeText.includes(name);
    });

    for (const allergy of allergies) {
        const recipeContainsAllergy = containsPositiveMention(recipeText, allergy);
        const usedIngredientContainsAllergy = usedIngredients.some(i => {
            return parseList(i.allergenes || i.allergens).some(item => item.includes(allergy));
        });

        if (recipeContainsAllergy || usedIngredientContainsAllergy) {
            score -= 80;
        }
    }

    return clamp(score);
};

const calculateDietScore = (recipeText, profile) => {
    let score = 100;
    const preferences = parseList(profile?.preferencesAlimentaires).join(" ");

    const meatWords = ["poulet", "viande", "boeuf", "veau", "agneau", "porc", "jambon", "dinde", "poisson", "thon", "saumon", "crevette"];
    const animalWords = [...meatWords, "oeuf", "lait", "fromage", "yaourt", "beurre", "miel"];
    const glutenWords = ["pain", "pate", "pates", "farine", "ble", "orge", "seigle", "couscous"];
    const lactoseWords = ["lait", "fromage", "yaourt", "creme", "beurre"];

    if ((preferences.includes("vegetarien") || preferences.includes("vegetarian")) && textIncludesAny(recipeText, meatWords)) {
        score -= 90;
    }

    if (preferences.includes("vegan") && textIncludesAny(recipeText, animalWords)) {
        score -= 95;
    }

    if ((preferences.includes("sans gluten") || preferences.includes("gluten free")) && textIncludesAny(recipeText, glutenWords)) {
        score -= 80;
    }

    if ((preferences.includes("sans lactose") || preferences.includes("lactose free")) && textIncludesAny(recipeText, lactoseWords)) {
        score -= 80;
    }

    return clamp(score);
};

const calculateNutritionScore = (recipe, profile) => {
    const targets = getNutritionTargets(profile);
    const calories = toNumber(recipe.calories);
    const protein = toNumber(recipe.proteines);
    const carbs = toNumber(recipe.glucides);
    const fat = toNumber(recipe.lipides);

    const calorieScore = calculateRangeScore(
        calories,
        targets.calories.idealMin,
        targets.calories.idealMax,
        targets.calories.hardMin,
        targets.calories.hardMax
    );

    const proteinScore = calculateRangeScore(
        protein,
        targets.protein.idealMin,
        targets.protein.idealMax,
        targets.protein.hardMin,
        targets.protein.hardMax
    );

    const carbScore = calculateRangeScore(
        carbs,
        targets.carbs.idealMin,
        targets.carbs.idealMax,
        targets.carbs.hardMin,
        targets.carbs.hardMax
    );

    const fatScore = calculateRangeScore(
        fat,
        targets.fat.idealMin,
        targets.fat.idealMax,
        targets.fat.hardMin,
        targets.fat.hardMax
    );

    return (
        calorieScore * 0.35 +
        proteinScore * 0.30 +
        carbScore * 0.20 +
        fatScore * 0.15
    );
};

const calculateHealthConditionScore = (recipe, recipeText, profile) => {
    let score = 100;
    const conditions = parseList(profile?.conditionsSante).join(" ");
    const calories = toNumber(recipe.calories);
    const carbs = toNumber(recipe.glucides);
    const fat = toNumber(recipe.lipides);

    if (conditions.includes("diabete") || conditions.includes("diabetes")) {
        if (carbs > 70) score -= 35;
        if (textIncludesAny(recipeText, ["sucre", "miel", "sirop", "dessert", "chocolat"])) score -= 25;
    }

    if (conditions.includes("hypertension") || conditions.includes("tension")) {
        if (textIncludesAny(recipeText, ["sale", "sel", "sauce soja", "bouillon cube", "charcuterie"])) score -= 25;
    }

    if (conditions.includes("cholesterol") || conditions.includes("cardiaque")) {
        if (fat > 35) score -= 25;
        if (textIncludesAny(recipeText, ["beurre", "creme", "frit", "friture", "fromage"])) score -= 20;
    }

    if (conditions.includes("obesite") || conditions.includes("surpoids")) {
        if (calories > 700) score -= 25;
        if (fat > 30) score -= 15;
    }

    return clamp(score);
};

const calculateIngredientScore = (recipeText, ingredients) => {
    const names = ingredients
        .map(i => normalizeText(i.nom))
        .filter(name => name.length >= 2);

    if (names.length === 0) return 50;

    const usedCount = names.filter(name => recipeText.includes(name)).length;
    const ratio = usedCount / names.length;

    return clamp(40 + ratio * 60);
};

exports.calculateMatchingScore = (recipe, profile, ingredients = []) => {
    const recipeText = getRecipeText(recipe);
    const cookingText = getRecipeCookingText(recipe);

    const safetyScore = calculateSafetyScore(cookingText, profile, ingredients);
    const dietScore = calculateDietScore(cookingText, profile);

    if (safetyScore < 30 || dietScore < 30) {
        return Math.round(Math.min(safetyScore, dietScore));
    }

    const nutritionScore = calculateNutritionScore(recipe, profile);
    const healthScore = calculateHealthConditionScore(recipe, recipeText, profile);
    const ingredientScore = calculateIngredientScore(cookingText, ingredients);

    const finalScore =
        safetyScore * 0.20 +
        dietScore * 0.15 +
        nutritionScore * 0.45 +
        healthScore * 0.10 +
        ingredientScore * 0.10;

    return Math.round(clamp(finalScore));
};
