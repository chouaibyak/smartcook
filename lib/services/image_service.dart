class ImageService {

  static String getMealDbImage(String foodName) {
    final name = foodName.toLowerCase().trim();

    final map = {

      // Viandes
      'poulet': 'Chicken',
      'chicken': 'Chicken',
      'viande': 'Beef',
      'beef': 'Beef',

      // Féculents
      'riz': 'Rice',
      'rice': 'Rice',
      'pomme de terre': 'Potato',
      'potato': 'Potato',

      // Produits laitiers
      'lait': 'Milk',
      'milk': 'Milk',
      'fromage': 'Cheese',
      'cheese': 'Cheese',
      'oeuf': 'Egg',
      'egg': 'Egg',

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

        // ✅ Retour ThemealDB normal
        return 'https://www.themealdb.com/images/ingredients/${entry.value}.png';
      }
    }

    return getImageForType(null);
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

        // ✅ image neutre
        return 'https://www.themealdb.com/images/ingredients/Chicken.png';
    }
  }
}