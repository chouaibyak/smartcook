class ImageService {
  static String getMealDbImage(String foodName) {
    final name = foodName.toLowerCase().trim();

    final map = {
      'poulet': 'Chicken',
      'chicken': 'Chicken',
      'riz': 'Rice',
      'rice': 'Rice',
      'lait': 'Milk',
      'milk': 'Milk',
      'tomate': 'Tomato',
      'tomato': 'Tomato',
      'carotte': 'Carrot',
      'carrot': 'Carrot',
      'oeuf': 'Egg',
      'egg': 'Egg',
      'viande': 'Beef',
      'beef': 'Beef',
      'pomme': 'Apple',
      'apple': 'Apple',
      'banane': 'Banana',
      'banana': 'Banana',
      'oignon': 'Onion',
      'onion': 'Onion',
      'pomme de terre': 'Potato',
      'potato': 'Potato',
      'fromage': 'Cheese',
      'cheese': 'Cheese',
    };

    for (final entry in map.entries) {
      if (name.contains(entry.key)) {
        return 'https://www.themealdb.com/images/ingredients/${entry.value}.png';
      }
    }

    return getImageForType(null);
  }

  static String getImageForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'viande':
      case 'meat':
        return 'https://www.themealdb.com/images/ingredients/Beef.png';

      case 'produits laitiers':
      case 'dairy':
      case 'dairy & eggs':
        return 'https://www.themealdb.com/images/ingredients/Milk.png';

      case 'fruits':
      case 'fruit':
        return 'https://www.themealdb.com/images/ingredients/Apple.png';

      case 'légumes':
      case 'vegetables':
        return 'https://www.themealdb.com/images/ingredients/Carrot.png';

      default:
        return 'https://www.themealdb.com/images/ingredients/Chicken.png';
    }
  }
}