const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.generateRecipesFromData = async (profile, ingredients) => {
    // Utilisation de Gemini 1.5 Flash (rapide et efficace pour le JSON)
    const model = genAI.getGenerativeModel({ 
        model: "gemini-1.5-flash",
        generationConfig: { responseMimeType: "application/json" } // Force la sortie en JSON
    });

    // Construction du contexte santé/profil
    const healthContext = `
    PROFIL NUTRITIONNEL DE L'UTILISATEUR :
    - Objectif : ${profile?.objectifNutritionnel || "Équilibré"}
    - Allergies : ${profile?.allergies || "Aucune"}
    - Préférences alimentaires : ${profile?.preferencesAlimentaires || "Aucune"}
    - Pathologies/Santé : ${profile?.conditionsSante || "Aucune"}
    `;

    // Liste des ingrédients réels provenant de la BDD
    const ingredientsList = ingredients.map(i => `${i.quantite} ${i.unite} de ${i.nom}`).join(", ");

    const prompt = `
    Tu es un expert en nutrition et chef cuisinier. 
    CONSIGNE : Génère 3 recettes basées EXCLUSIVEMENT sur ces ingrédients.
    
    ${healthContext}
    
    INGRÉDIENTS DISPONIBLES : ${ingredientsList}

    FORMAT DE RÉPONSE (JSON LISTE) :
    [
      {
        "nom": "Nom court",
        "imageUrl": "Génère une URL Unsplash réaliste basée sur le nom de la recette au format : https://source.unsplash.com/800x600/?food,[nom_de_la_recette_en_anglais]",
        "typeRepas": "déjeuner/dîner",
        "tempsPreparation": minutes,
        "difficulte": "facile/moyen",
        "nbPersonnes": 2,
        "etapes": "1. ...",
        "calories": kcal,
        "proteines": g,
        "glucides": g,
        "lipides": g,
        "benefices": "...",
        "conseilsSante": "...",
        "scoreCompatibilite": 95
      }
    ]
    `;

    try {
        const result = await model.generateContent(prompt);
        const response = result.response;
        return JSON.parse(response.text());
    } catch (error) {
        console.error("Erreur Gemini API:", error);
        return null;
    }
};