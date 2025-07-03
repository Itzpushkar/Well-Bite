import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

final List<Map<String, String>> dailyChallenges = [
  {
    "title": "Hydration Day",
    "image": "https://example.com/water.png",
    "description": "Drink at least 8 glasses of water today. Start with 1 glass after waking up. Use a water bottle to track progress. Space your intake throughout the day.",
    "requirements": "Access to clean drinking water"
  },
  {
    "title": "Morning Stretch",
    "image": "https://example.com/stretch.png",
    "description": "Perform a 10-minute full-body stretch right after waking up.",
    "requirements": "Mat or soft surface"
  },
  {
    "title": "Fruit Frenzy",
    "image": "https://example.com/fruits.png",
    "description": "Eat at least 2 servings of fresh fruit today.",
    "requirements": "Fresh fruits"
  },
  {
    "title": "Core Blast",
    "image": "https://example.com/core.png",
    "description": "Perform this core workout:\n- 3 sets of 30-sec planks\n- 3 sets of 20 crunches\n- 3 sets of 15 leg raises",
    "requirements": "Comfortable clothing, mat"
  },
  {
    "title": "Veggie Variety",
    "image": "https://example.com/veggies.png",
    "description": "Eat at least 3 different colored vegetables during the day.",
    "requirements": "Access to fresh vegetables"
  },
  {
    "title": "Walk 5K",
    "image": "https://example.com/walk.png",
    "description": "Take a 5-kilometer brisk walk today.",
    "requirements": "Walking shoes, open space"
  },
  {
    "title": "No Sugar Day",
    "image": "https://example.com/nosugar.png",
    "description": "Avoid all added sugar for the entire day.",
    "requirements": "Awareness of food labels, food log (optional)"
  },
];

class ChallengeTab extends StatefulWidget {
  final Color background;

  ChallengeTab({Key? key, required this.background}) : super(key: key);

  @override
  State<ChallengeTab> createState() => _ChallengeTabState();
}

class _ChallengeTabState extends State<ChallengeTab> {
  bool isUserLoggedIn = true;
  bool challengeClicked = false;
  late Timer _timer;
  Duration remainingTime = Duration.zero;

  int get currentDayIndex => DateTime.now().weekday % dailyChallenges.length;

  @override
  void initState() {
    super.initState();
    _loadChallengeState();
    _checkTimer();
    _startMidnightTimer();
  }

  Future<void> _loadChallengeState() async {
    final prefs = await SharedPreferences.getInstance();
    final clicked = prefs.getBool("challengeClicked") ?? false;
    final lastDate = prefs.getString("lastClickedDate") ?? "";
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (clicked && lastDate == today) {
      setState(() {
        challengeClicked = true;
      });
    }
  }

  void _checkTimer() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0);
    remainingTime = nextMidnight.difference(now).isNegative ? Duration.zero : nextMidnight.difference(now);
  }

  void _startMidnightTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final now = DateTime.now();
      final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0);

      if (challengeClicked) {
        if (mounted) {
          setState(() {
            remainingTime = nextMidnight.difference(now);
          });
        }

        if (remainingTime <= Duration.zero) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool("challengeClicked", false);
          await prefs.setString("lastClickedDate", "");

          if (mounted) {
            setState(() {
              challengeClicked = false;
            });
          }
        }
      }
    });
  }

  bool _isWithinChallengeTime() {
    final now = DateTime.now();
    return now.hour >= 19 && now.hour <= 23;
  }

  void _onChallengeClick() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    await prefs.setBool("challengeClicked", true);
    await prefs.setString("lastClickedDate", today);

    setState(() {
      challengeClicked = true;
    });

    _checkTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final withinTime = _isWithinChallengeTime();
    final challenge = dailyChallenges[currentDayIndex];

    return Scaffold(
      backgroundColor: widget.background,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.orange.shade200, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Expanded(
                child: challengeClicked
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_bottom, size: 60, color: Colors.orange),
                      const SizedBox(height: 16),
                      const Text(
                        "Next challenge is coming...",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Time remaining: ${remainingTime.inHours.toString().padLeft(2, '0')}:${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        challenge["title"]!,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          challenge["image"]!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(child: Text("Image not available")),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Description:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge["description"]!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Requirements:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge["requirements"]!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      if (isUserLoggedIn)
                        Container(
                          height: 95,
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: MouseRegion(
                                  cursor: withinTime
                                      ? SystemMouseCursors.click
                                      : SystemMouseCursors.forbidden,
                                  child: ElevatedButton.icon(
                                    onPressed: withinTime ? _onChallengeClick : null,
                                    icon: Icon(Icons.check_circle, color: Colors.white),
                                    label: Text("Completed"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      disabledBackgroundColor: Colors.green.shade200,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      minimumSize: Size.fromHeight(50),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: MouseRegion(
                                  cursor: withinTime
                                      ? SystemMouseCursors.click
                                      : SystemMouseCursors.forbidden,
                                  child: ElevatedButton.icon(
                                    onPressed: withinTime ? _onChallengeClick : null,
                                    icon: Icon(Icons.cancel, color: Colors.white),
                                    label: Text("Missed"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      disabledBackgroundColor: Colors.red.shade200,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      minimumSize: Size.fromHeight(50),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text("Login to participate in this challenge."),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
