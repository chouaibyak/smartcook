const fs = require('fs/promises');
const path = require('path');
const axios = require('axios');

const imagesDir = path.join(__dirname, '..', 'public', 'recipe-images');
const usedImageUrls = new Set();

const http = axios.create({
    timeout: 20000,
    headers: {
        "User-Agent": "SmartCook/1.0 (recipe image downloader)",
        "Accept": "application/json,image/*,*/*"
    }
});

const slugify = (text) => {
    return String(text || "recipe")
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "")
        .slice(0, 50);
};

const imageExtension = (mimeType = "") => {
    if (mimeType.includes("png")) return "png";
    if (mimeType.includes("webp")) return "webp";
    return "jpg";
};

const cleanSearchText = (text) => {
    return String(text || "")
        .replace(/professional|realistic|food photography|gourmet plating|close up|highly detailed/gi, " ")
        .replace(/single finished dish|on a plate|natural light|no text|no logo/gi, " ")
        .replace(/[^\p{L}\p{N}\s]/gu, " ")
        .replace(/\s+/g, " ")
        .trim();
};

const getSearchQueries = (recipe) => {
    const promptQuery = cleanSearchText(recipe.imagePrompt);
    const nameQuery = cleanSearchText(recipe.nom);

    return [
        promptQuery && `${promptQuery} food`,
        nameQuery && `${nameQuery} plat cuisine`,
        nameQuery && `${nameQuery} food`,
        "chicken rice onion dish",
        "cooked chicken rice plate"
    ].filter(Boolean);
};

const searchOpenverse = async (query) => {
    const response = await http.get("https://api.openverse.org/v1/images/", {
        params: {
            q: query,
            page_size: 20,
            mature: false,
            categories: "photograph"
        }
    });

    return (response.data?.results || [])
        .map(item => item.url || item.thumbnail)
        .filter(Boolean);
};

const searchWikimedia = async (query) => {
    const response = await http.get("https://commons.wikimedia.org/w/api.php", {
        params: {
            action: "query",
            generator: "search",
            gsrsearch: `${query} food`,
            gsrnamespace: 6,
            gsrlimit: 20,
            prop: "imageinfo",
            iiprop: "url|mime",
            iiurlwidth: 900,
            format: "json",
            origin: "*"
        }
    });

    return Object.values(response.data?.query?.pages || {})
        .flatMap(page => page.imageinfo || [])
        .filter(info => String(info.mime || "").startsWith("image/"))
        .map(info => info.thumburl || info.url)
        .filter(Boolean);
};

const downloadImage = async (imageUrl) => {
    const response = await http.get(imageUrl, {
        responseType: "arraybuffer",
        maxRedirects: 5,
        headers: { Accept: "image/*,*/*" }
    });

    const mimeType = response.headers["content-type"] || "";

    if (!mimeType.startsWith("image/")) {
        throw new Error(`URL ne retourne pas une image (${mimeType || "type inconnu"})`);
    }

    return {
        buffer: Buffer.from(response.data),
        mimeType
    };
};

const findRealRecipeImage = async (recipe, index) => {
    const queries = getSearchQueries(recipe);

    for (const query of queries) {
        console.log(`Recherche vraie photo pour "${recipe.nom}" avec: ${query}`);

        const candidates = [
            ...await searchOpenverse(query).catch(error => {
                console.error("Openverse indisponible:", error.message);
                return [];
            }),
            ...await searchWikimedia(query).catch(error => {
                console.error("Wikimedia indisponible:", error.message);
                return [];
            })
        ].filter(url => !usedImageUrls.has(url));

        const orderedCandidates = [
            ...candidates.slice(index),
            ...candidates.slice(0, index)
        ];

        for (const imageUrl of orderedCandidates.slice(0, 8)) {
            try {
                const image = await downloadImage(imageUrl);
                usedImageUrls.add(imageUrl);
                console.log(`Photo trouvee pour "${recipe.nom}"`);
                return image;
            } catch (error) {
                console.error("Image candidate ignoree:", error.message);
            }
        }
    }

    throw new Error(`Aucune vraie photo trouvee pour ${recipe.nom}`);
};

exports.generateRecipeImage = async (recipe, req, index) => {
    const visualKeyword = recipe.nom || "recipe";

    await fs.mkdir(imagesDir, { recursive: true });

    let image;
    try {
        image = await findRealRecipeImage(recipe, index);
    } catch (error) {
        console.error(`Image fallback pour "${recipe.nom}":`, error.message);
        return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80";
    }

    const ext = imageExtension(image.mimeType);
    const fileName = `${slugify(visualKeyword)}-${index}-${Date.now()}.${ext}`;
    const filePath = path.join(imagesDir, fileName);
    const publicUrl = `${req.protocol}://${req.get('host')}/recipe-images/${fileName}`;

    await fs.writeFile(filePath, image.buffer);
    return publicUrl;
};
