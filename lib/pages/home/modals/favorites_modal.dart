import 'package:flutter/material.dart';

class FavoritesModal extends StatelessWidget {
  final List<dynamic> favorites;
  final String tabName;
  final Function(dynamic)? onRemove;

  const FavoritesModal({
    Key? key,
    required this.favorites,
    required this.tabName,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: favorites.isEmpty
          ? Center(child: Text('No favorites in $tabName tab yet.'))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final item = favorites[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.teal.withOpacity(0.1),
              onTap: () {}, // Optional interaction
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade50, Colors.teal.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(tabName=="unique" ? Icons.format_quote : Icons.fastfood, color: Colors.teal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tabName=="unique" ?item['author'].toString().toUpperCase() :
                            item['name'].toString().toUpperCase()  ,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            if (onRemove != null) {
                              onRemove!(item);
                            } else {
                              Navigator.pop(context, item);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getSubtitle(item),
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSubtitle(dynamic item) {
    String format(dynamic val) {
      if (val is num) return val.toStringAsFixed(1);
      if (val == null || val.toString().isEmpty) return "Not Available";
      return val.toString();
    }

    if (item.containsKey('calories') && item.containsKey('protein_g')) {
      // Food tab
      return '''
Calories: ${format(item['calories'])}
Protein: ${format(item['protein_g'])}g
Fat: ${format(item['fat_total_g'])}g
Saturated Fat: ${format(item['fat_saturated_g'])}
Carbs: ${format(item['carbohydrates_total_g'])}g
Fiber: ${format(item['fiber_g'])}g
Sugar: ${format(item['sugar_g'])}g
Sodium: ${format(item['sodium_mg'])}mg
Cholesterol: ${format(item['cholesterol_mg'])}mg
Potassium: ${format(item['potassium_mg'])}mg
''';
    } else if (item.containsKey('type') && item.containsKey('muscle')) {
      // Exercise tab
      return '''
Type: ${format(item['type'])}
Muscle: ${format(item['muscle'])}
Equipment: ${format(item['equipment'])}
Difficulty: ${format(item['difficulty'])}
Instructions: ${format(item['instructions'])}
''';
    }  else if (item.containsKey('quote')) {
      return item['quote'];
    }

    return "Details not available";
  }

}
