class Ingredient {
  String name;
  double quantity;
  String unit;
  String type;
  DateTime? expirationDate;
  double calories;
  double proteins;
  double carbs;
  double fats;

  Ingredient({
    this.name = '',
    this.quantity = 0,
    this.unit = 'Grams (g)',
    this.type = 'Vegetables',
    this.expirationDate,
    this.calories = 0,
    this.proteins = 0,
    this.carbs = 0,
    this.fats = 0,
  });
}