import 'package:flutter/material.dart';

class HomeTabBar extends StatelessWidget {
  final TabController tabController;
  final int selectedTabIndex;
  final ValueChanged<int> onTap;
  final Color indicatorColor;

  const HomeTabBar({
    Key? key,
    required this.tabController,
    required this.selectedTabIndex,
    required this.onTap,
    required this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Material(
        color: Colors.transparent,
        child: TabBar(
          controller: tabController,
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          onTap: onTap,
          indicator: selectedTabIndex == -1
              ? const BoxDecoration(color: Colors.transparent)
              : BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(35),
          ),
          indicatorColor: Colors.transparent,
          indicatorWeight: 0,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          dividerColor: Colors.transparent,
          tabs: List.generate(3, (index) {
            IconData icon;
            String text;

            switch (index) {
              case 0:
                icon = Icons.fastfood;
                text = 'Food';
                break;
              case 1:
                icon = Icons.fitness_center;
                text = 'Exercise';
                break;
              case 2:
                icon = Icons.emoji_events;
                text = 'Grind';
                break;
              default:
                icon = Icons.help;
                text = 'Unknown';
            }

            return Tab(
              child: SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
