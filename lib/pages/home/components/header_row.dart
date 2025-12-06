import 'package:flutter/material.dart';

class HeaderRow extends StatelessWidget {
  final VoidCallback onDrawerPressed;
  final VoidCallback onFavoritesPressed;
  final VoidCallback onThemeTogglePressed;
  final bool isDarkTheme;
  final String title;
  final String currentTabKey;
  final dynamic buttonColor;

  const HeaderRow({
    Key? key,
    required this.currentTabKey,
    required this.onDrawerPressed,
    required this.onFavoritesPressed,
    required this.onThemeTogglePressed,
    required this.isDarkTheme,
    required this.buttonColor,
    this.title = "Wellbite",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconThemeToggle = isDarkTheme ? Icons.wb_sunny : Icons.nightlight_round;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Drawer button
          _iconCircleButton(icon: Icons.menu, onTap: onDrawerPressed),

          // Title centered horizontally
          Expanded(
            child: Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Favorite & theme toggle buttons
          Row(
            children: [
              if(currentTabKey!="challenge" && currentTabKey!="unique" && currentTabKey!="community" ) _iconCircleButton(icon: Icons.favorite_border, onTap: onFavoritesPressed),
              const SizedBox(width: 10),
              _iconCircleButton(icon: iconThemeToggle, onTap: onThemeTogglePressed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconCircleButton({required IconData icon, required VoidCallback onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black),
        ),
    ));
  }
}
