import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FoodTab extends StatefulWidget {
  final List<dynamic> foodResults;
  final List<dynamic> defaultFoodList;
  final List<dynamic> favorites;
  final Function(dynamic) onToggleFavorite;
  final bool isLoading;
  final String searchQuery;
  final Color currentThemeColor;

  const FoodTab({
    Key? key,
    required this.foodResults,
    required this.defaultFoodList,
    required this.isLoading,
    required this.favorites,
    required this.onToggleFavorite,
    required this.searchQuery,
    required this.currentThemeColor,
  }) : super(key: key);

  @override
  State<FoodTab> createState() => _FoodTabState();
}

class _FoodTabState extends State<FoodTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: SpinKitFadingCircle(color: Colors.teal, size: 50),
      );
    }

    final themeColor = widget.currentThemeColor;
    final showSearchResults = widget.searchQuery.isNotEmpty;
    final dataList = showSearchResults ? widget.foodResults : widget.defaultFoodList;

    if (showSearchResults && dataList.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    if (dataList.isEmpty) {
      return const Center(child: Text('No food data available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final item = dataList[index];
        final isFavorite = widget.favorites.any((f) => f['name'] == item['name']);
        return _UnifiedTile(
          title: item['name'],
          isFavorite: isFavorite,
          onToggleFavorite: () => widget.onToggleFavorite(item),
          tags: [
            "Carbs: ${item['carbohydrates_total_g']}g",
            "Fiber: ${item['fiber_g']}g",
          ],
          details: [
            "Fat: ${item['fat_total_g']}g",
            "Saturated Fat: ${item['fat_saturated_g']}g",
            "Sugar: ${item['sugar_g']}g",
            "Carbs: ${item['carbohydrates_total_g']}g",
            "Fiber: ${item['fiber_g']}g",
            "Sodium: ${item['sodium_mg']}mg",
            "Potassium: ${item['potassium_mg']}mg",
            "Cholesterol: ${item['cholesterol_mg']}mg",
          ],
          themeColor: themeColor,
        );
      },
    );
  }
}

class _UnifiedTile extends StatefulWidget {
  final String title;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final List<String> tags;
  final List<String> details;
  final Color themeColor;

  const _UnifiedTile({
    required this.title,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.tags,
    required this.details,
    required this.themeColor,
  });

  @override
  State<_UnifiedTile> createState() => _UnifiedTileState();
}

class _UnifiedTileState extends State<_UnifiedTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.green.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.themeColor,
                  ),
                  onPressed: widget.onToggleFavorite,
                ),
                IconButton(
                  icon: AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: _expanded ? 0.5 : 0.0,
                    child: Icon(Icons.expand_more, color: Colors.green[200],),
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                )

              ],
            ),

            const SizedBox(height: 8),
            if (!_expanded)
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: widget.tags.map((tag) => _tag(tag)).toList(),
              ),
            AnimatedCrossFade(
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.details.map((d) => _infoRow(d)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
