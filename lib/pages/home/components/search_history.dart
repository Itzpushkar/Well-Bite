import 'package:flutter/material.dart';

class SearchHistory extends StatelessWidget {
  final List<String> historyItems;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onClearAll;

  const SearchHistory({
    Key? key,
    required this.historyItems,
    required this.onItemSelected,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (historyItems.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                return GestureDetector(
                  onTap: () => onItemSelected(item),
                  child: Chip(
                    label: Text(item),
                    backgroundColor: Colors.grey.shade100,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
            ),
          ),
          IconButton(
            icon: Icon(Icons.clear, color: Colors.black,),
            tooltip: 'Clear History',
            onPressed: onClearAll,
          ),
        ],
      ),
    );
  }
}
