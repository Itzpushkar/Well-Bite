class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final String? id; // optional if API returns some unique id

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    this.id,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein_g'] ?? 0).toDouble(),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'calories': calories,
    'protein_g': protein,
    if (id != null) 'id': id,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FoodItem &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              calories == other.calories &&
              protein == other.protein;

  @override
  int get hashCode => name.hashCode ^ calories.hashCode ^ protein.hashCode;
}
