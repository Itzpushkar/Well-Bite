import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color selectedColor;
  final Color unselectedColor;

  const HomeBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.selectedColor = const Color(0xFFFFD700),
    this.unselectedColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navButton("Unique", Icons.star, 0),
          _navButton("Community", Icons.people, 1),
        ],
      ),
    );
  }

  Widget _navButton(String label, IconData icon, int index) {
    final bool isSelected = selectedIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.black : unselectedColor),
              Text(
                label,
                style: TextStyle(color: isSelected ? Colors.black : unselectedColor),
              ),
            ],
          ),
        ),
    )
    );
  }
}
