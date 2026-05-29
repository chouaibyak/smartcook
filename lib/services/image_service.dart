class ImageService {
  static bool isUsableImageUrl(String? url) {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return false;

    final lower = value.toLowerCase();
    if (lower == 'null' || lower == 'undefined') return false;

    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static String resolveIngredientImage(
    String foodName,
    String? type, [
    String? imageUrl,
  ]) {
    final value = imageUrl?.trim();
    return isUsableImageUrl(value) ? value! : getMealDbImage(foodName, type);
  }

  static String _mealDbIngredientUrl(String ingredient) {
    return 'https://www.themealdb.com/images/ingredients/${Uri.encodeComponent(ingredient)}.png';
  }

  static String getMealDbImage(String foodName, [String? type]) {
    final name = foodName.toLowerCase().trim();

    final map = {

      // Viandes
      'poulet': 'Chicken',
      'chicken': 'Chicken',
      'viande': 'Beef',
      'beef': 'Beef',
      'boeuf': 'Beef',
      'bœuf': 'Beef',
      'agneau': 'Lamb',
      'porc': 'Pork',
      'jambon': 'Ham',

      // Féculents
      'riz': 'Rice',
      'rice': 'Rice',
      'pomme de terre': 'Potato',
      'potato': 'Potato',
      'pates': 'Pasta',
      'pâtes': 'Pasta',
      'pasta': 'Pasta',
      'pain': 'Bread',
      'bread': 'Bread',
      'farine': 'Flour',

      // Produits laitiers
      'lait': 'Milk',
      'milk': 'Milk',
      'fromage': 'Cheese',
      'cheese': 'Cheese',
      'oeuf': 'Egg',
      'oeufs': 'Egg',
      'œuf': 'Egg',
      'œufs': 'Egg',
      'egg': 'Egg',
      'beurre': 'Butter',
      'butter': 'Butter',
      'yaourt': 'Yogurt',
      'yogurt': 'Yogurt',

      // Fruits & légumes
      'tomate': 'Tomato',
      'tomato': 'Tomato',
      'carotte': 'Carrot',
      'carrot': 'Carrot',
      'pomme': 'Apple',
      'apple': 'Apple',
      'banane': 'Banana',
      'banana': 'Banana',
      'oignon': 'Onion',
      'onion': 'Onion',
      'ail': 'Garlic',
      'garlic': 'Garlic',
      'citron': 'Lemon',
      'lemon': 'Lemon',
      'orange': 'Orange',
      'fraise': 'Strawberries',
      'strawberry': 'Strawberries',
      'salade': 'Lettuce',
      'lettuce': 'Lettuce',
      'concombre': 'Cucumber',
      'cucumber': 'Cucumber',
      'champignon': 'Mushrooms',
      'mushroom': 'Mushrooms',

      // Poissons et fruits de mer
      'thon': 'Tuna',
      'tuna': 'Tuna',
      'saumon': 'Salmon',
      'salmon': 'Salmon',
      'crevette': 'Prawns',
      'shrimp': 'Prawns',

      // Produits industriels
      'nutella': 'Nutella',
      'oreo': 'Oreo',
      'coca': 'Coca',
      'pepsi': 'Pepsi',
    };

    for (final entry in map.entries) {

      if (name.contains(entry.key)) {

        // Images spéciales
        if (entry.value == 'Nutella') {
          return 'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?q=80&w=800';
        }

        if (entry.value == 'Oreo') {
          return 'https://images.unsplash.com/photo-1614707267537-b85aaf00c4b7?q=80&w=800';
        }

        if (entry.value == 'Coca') {
          return 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?q=80&w=800';
        }

        if (entry.value == 'Pepsi') {
          return 'https://images.unsplash.com/photo-1581006852262-e4307cf6283a?q=80&w=800';
        }

        return _mealDbIngredientUrl(entry.value);
      }
    }

    return getImageForType(type);
  }

  static String getImageForType(String? type) {

    switch (type?.toLowerCase()) {

      case 'snacks':
      case 'snack':
        return 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?q=80&w=800';

      case 'drink':
      case 'drinks':
      case 'boisson':
      case 'boissons':
        return 'https://images.unsplash.com/photo-1544145945-f90425340c7e?q=80&w=800';

      case 'spices':
        return 'https://images.unsplash.com/photo-1509358271058-acd22cc93898?q=80&w=800';

      case 'seafood':
      case 'poisson':
      case 'fruits de mer':
        return _mealDbIngredientUrl('Salmon');

      case 'grains':
      case 'cereals':
      case 'céréales':
      case 'féculents':
        return _mealDbIngredientUrl('Rice');

      case 'bakery':
      case 'boulangerie':
        return _mealDbIngredientUrl('Bread');

      case 'frozen':
      case 'surgelés':
        return _mealDbIngredientUrl('Peas');

      case 'organic':
      case 'bio':
        return _mealDbIngredientUrl('Apple');

      case 'canned food':
      case 'conserve':
      case 'conserves':
        return _mealDbIngredientUrl('Tomato');

      case 'sauces':
      case 'sauce':
        return _mealDbIngredientUrl('Soy Sauce');

      case 'sweets':
      case 'sweet':
      case 'sucreries':
        return _mealDbIngredientUrl('Sugar');

      case 'breakfast':
      case 'petit déjeuner':
        return _mealDbIngredientUrl('Egg');

      case 'viande':
      case 'meat':
        return _mealDbIngredientUrl('Beef');

      case 'produits laitiers':
      case 'dairy':
      case 'dairy & eggs':
        return _mealDbIngredientUrl('Milk');

      case 'fruits':
      case 'fruit':
        return _mealDbIngredientUrl('Apple');

      case 'légumes':
      case 'vegetables':
        return _mealDbIngredientUrl('Carrot');

      default:

        return _mealDbIngredientUrl('Apple');
    }
  }
}
