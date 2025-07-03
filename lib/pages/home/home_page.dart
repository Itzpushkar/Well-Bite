
  import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
  import 'package:wellbite/pages/home/tabs/edit_profile_dialoag.dart';

  import '../../fancy_well_bite_login.dart';
  import '../update_profile_page.dart';
  import '/services/api_service.dart';
  import '/services/firestore_service.dart';

  import 'components/header_row.dart';
  import 'components/search_bar.dart';
  import 'components/tab_bar.dart';
  import 'components/bottom_nav_bar.dart';
  import 'components/search_history.dart';
  import 'components/floating_button.dart';

  import 'modals/favorites_modal.dart';

  import 'tabs/food_tab.dart';
  import 'tabs/exercise_tab.dart';
  import 'tabs/challenge_tab.dart';
  import 'tabs/unique_tab.dart';
  import 'tabs/community_tab.dart';

  class HomePage extends StatefulWidget {
    const HomePage({Key? key}) : super(key: key);

    @override
    State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final FirebaseAuth _auth = FirebaseAuth.instance;
    late final User currentUser;

    final Map<String, List<dynamic>> defaultResultsMap = {};

    late final ApiService apiService;
    late final FirestoreService firestoreService;

    late TabController tabController;
    int selectedTabIndex = 0;
    int selectedBottomIndex = -1;
    bool isDarkTheme = false;

    final Map<String, TextEditingController> searchControllers = {};
    final Map<String, List<String>> searchHistories = {};
    final Map<String, List<dynamic>> favorites = {};
    final Map<String, bool> isLoadingMap = {};
    final Map<String, List<dynamic>> resultsMap = {};
    dynamic defaultQuote = {"text": "Please press shuffle button to view quote"};

    static const List<String> tabNames = ['food', 'exercise', 'challenge'];
    static const List<String> bottomNames = ['unique', 'community'];

    String get currentTabKey => selectedBottomIndex != -1 ? bottomNames[selectedBottomIndex] : tabNames[selectedTabIndex];

    void initState() {
      super.initState();
      currentUser = _auth.currentUser!;
      apiService = ApiService(apiKey: 'Add Your API Key');
      firestoreService = FirestoreService(userId: currentUser.uid);

      tabController = TabController(length: tabNames.length, vsync: this);
      tabController.addListener(() {
        if (tabController.indexIsChanging) {
          _onTabSelected(tabController.index);
        }
      });


      for (var key in [...tabNames, ...bottomNames]) {
        searchControllers[key] = TextEditingController();
        searchHistories[key] = [];
        favorites[key] = [];
        isLoadingMap[key] = false;
        resultsMap[key] = [];
      }

      _loadDataForAllTabs();
      _fetchDefaultItems('food');
    }

    @override
    void dispose() {
      for (var controller in searchControllers.values) {
        controller.dispose();
      }
      tabController.dispose();
      super.dispose();
    }

    Future<void> _loadDataForAllTabs() async {
      for (var key in [...tabNames, ...bottomNames]) {
        final hist = await firestoreService.getSearchHistory(key);
        final fav = await firestoreService.getFavorites(key);
        setState(() {
          searchHistories[key] = hist;
          favorites[key] = fav;
        });
      }
    }

    Future<void> _fetchDefaultItems(String key) async {
      if (key == 'community') return;
      setState(() => isLoadingMap[key] = true);

      try {
        List<String> defaultQueries = _defaultQueriesForTab(key);
        List<dynamic> combinedResults = [];

        for (var query in defaultQueries) {
          List<dynamic> res = [];
          if (key == 'food') {
            res = await apiService.fetchNutritionData(query);
          } else if (key == 'exercise') {
            res = await apiService.fetchExerciseData(query);
          }
          combinedResults.addAll(res);
        }

        setState(() {
          resultsMap[key] = combinedResults;
          defaultResultsMap[key] = combinedResults;
        });
      } catch (e) {
        // Optionally show error
      } finally {
        setState(() => isLoadingMap[key] = false);
      }
    }

    List<String> _defaultQueriesForTab(String key) {
      switch (key) {
        case 'food': return ['pizza', 'paneer', 'burger'];
        case 'exercise': return ['running', 'yoga'];
        case 'unique': return ['unique'];
        default: return [];
      }
    }


    void _onTabSelected(int index) {
      setState(() {
        selectedTabIndex = index;
        selectedBottomIndex = -1;
        tabController.index = index;
        searchControllers[currentTabKey]?.clear();
      });
      _maybeFetchDefaultIfEmpty(currentTabKey);
    }

    void _onBottomTabSelected(int index) {
      setState(() {
        selectedBottomIndex = index;
        selectedTabIndex = -1;
        searchControllers[currentTabKey]?.clear();
      });
      _maybeFetchDefaultIfEmpty(currentTabKey);
    }

    void _maybeFetchDefaultIfEmpty(String key) {
      if ((resultsMap[key]?.isEmpty ?? true) && key != 'community') {
        _fetchDefaultItems(key);
      }
    }

    void _toggleFavorite(String key, dynamic item) {
      final favList = favorites[key]!;
      final existingIndex = favList.indexWhere((f) => f['name'] == item['name']);
      setState(() {
        if (existingIndex != -1) {
          favList.removeAt(existingIndex);
        } else {
          favList.add(item);
        }
      });
      firestoreService.saveFavorites(key, favList);
    }

    Future<Map<String, String>> _fetchQuote() async {
      final response = await http.get(Uri.parse('YOUR_API_ENDPOINT'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final quoteData = Map<String, dynamic>.from(data[0]);
          return {
            'quote': quoteData['quote'] ?? '',
            'author': quoteData['author'] ?? ''
          };
        } else {
          throw Exception('Empty quote list');
        }
      } else {
        throw Exception('Failed to load quote');
      }
    }



    Future<void> _performSearch(String key) async {
      final query = searchControllers[key]?.text.trim() ?? '';
      if (query.isEmpty) return;

      setState(() {
        isLoadingMap[key] = true;
        resultsMap[key] = [];
        searchControllers[key]?.text = query; // ✅ Ensure searchQuery sync
      });

      try {
        List<dynamic> results = [];
        if (key == 'food') {
          results = await apiService.fetchNutritionData(query);
        } else if (key == 'exercise') {
          results = await apiService.fetchExerciseData(query);
        }

        setState(() {
          resultsMap[key] = results;
          if (!searchHistories[key]!.contains(query)) {
            searchHistories[key]!.insert(0, query);
            if (searchHistories[key]!.length > 10) {
              searchHistories[key] = searchHistories[key]!.sublist(0, 10);
            }
            firestoreService.saveSearchHistory(key, searchHistories[key]!);
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search failed. Try again.')),
        );
      } finally {
        setState(() => isLoadingMap[key] = false);
      }
    }

    Color get currentThemeColor {
      if (selectedTabIndex == 0) return Colors.green.shade200;
      if (selectedTabIndex == 1) return Colors.blue.shade200;
      if (selectedTabIndex == 2) return Colors.orange.shade200;
      return Colors.grey;
    }

    void _clearSearch(String key) {
      searchControllers[key]?.text = ''; // ✅ Clear controller value
      setState(() => resultsMap[key] = defaultResultsMap[key] ?? []);
    }
    void _clearSearchHistory(String key) {
      setState(() => searchHistories[key] = []);
      firestoreService.saveSearchHistory(key, []);
    }

    void _showFavoritesModal() {
      final key = currentTabKey;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => FavoritesModal(
          favorites: favorites[key]!,
          tabName: key,
          onRemove: (item) {
            Navigator.pop(context);
            _toggleFavorite(key, item);
          },
        ),
      );
    }

    void _toggleTheme() => setState(() => isDarkTheme = !isDarkTheme);

    void drawerOpen() => _scaffoldKey.currentState?.openDrawer();

    @override
    Widget build(BuildContext context) {
      final key = currentTabKey;
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDarkTheme ? Colors.blueGrey.shade100 : const Color(0xFFE6F0FF),
        drawer: _buildDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              HeaderRow(
                onDrawerPressed: drawerOpen,
                onFavoritesPressed: _showFavoritesModal,
                onThemeTogglePressed: _toggleTheme,
                isDarkTheme: isDarkTheme,
                buttonColor: const Color(0xFFFFD700),
              ),
              SearchBar1(
                controller: searchControllers[key]!,
                hintText: _getSearchHint(key),
                onClear: () => _clearSearch(key),
                onSearch: () => _performSearch(key),
                currentThemeColor: currentThemeColor,
              ),
              SearchHistory(
                historyItems: searchHistories[key]!,
                onItemSelected: (item) {
                  searchControllers[key]!.text = item;
                  _performSearch(key);
                },
                onClearAll: () => _clearSearchHistory(key),
              ),
              const SizedBox(height: 10),
              HomeTabBar(
                tabController: tabController,
                selectedTabIndex: selectedTabIndex,
                onTap: _onTabSelected,
                indicatorColor: currentThemeColor,
              ),
              Expanded(child: _buildTabContent(key)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionBtn(
          isFormFilled: false,
          onPressed: () {},
          backgroundColor: currentThemeColor,
        ),
        bottomNavigationBar: HomeBottomNavBar(
          selectedIndex: selectedBottomIndex,
          onTabSelected: _onBottomTabSelected,
          selectedColor: currentThemeColor,
        ),
      );
    }

    Widget _buildDrawer() {
      return Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final userData = snapshot.data!.data() as Map<String, dynamic>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Row with Profile Picture + Hello + Name
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage('assets/user.png'),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Hello!",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      userData['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          _infoTile(Icons.email, userData['email'] ?? ''),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: _infoTile(Icons.height, 'Height: ${userData['height'] ?? ''} cm'),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _infoTile(Icons.monitor_weight, 'Weight: ${userData['weight'] ?? ''} kg'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: _infoTile(Icons.cake, 'Age: ${userData['age'] ?? ''}'),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _infoTile(Icons.flag, userData['goal'] ?? ''),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _drawerButton(
                            icon: Icons.edit,
                            label: 'Update Profile',
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => EditProfileDialog(
                                  userId: FirebaseAuth.instance.currentUser!.uid,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          _drawerButton(
                            icon: Icons.settings,
                            label: 'Settings',
                            onTap: () {
                              Navigator.pop(context); // Close the drawer
                              showDialog(
                                context: context,
                                builder: (context) => _showSettingsDialog(context),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const FancyWellBiteLogin()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );



    }

    Widget _buildTabContent(String key) {
      final isLoading = isLoadingMap[key] ?? false;
      final results = resultsMap[key] ?? [];
      final favs = favorites[key]!;
      final query = searchControllers[key]?.text ?? '';
      final defaultList = defaultResultsMap[key] ?? [];

      if (key == 'food') {
        return FoodTab(
          foodResults: results,
          isLoading: isLoading,
          favorites: favs,
          onToggleFavorite: (item) => _toggleFavorite(key, item),
          searchQuery: query,
          defaultFoodList: defaultList,
          currentThemeColor: currentThemeColor,
        );
      } else if (key == 'exercise') {
        return ExerciseTab(
          exerciseResults: results,
          defaultExerciseList: defaultList ?? [],
          isLoading: isLoading,
          favorites: favs,
          onToggleFavorite: (item) => _toggleFavorite(key, item),
          searchQuery: query,
          currentThemeColor: currentThemeColor,
        );
        } else if (key == 'challenge') {
          return ChallengeTab(
            background: isDarkTheme ? Colors.blueGrey.shade100 : const Color(0xFFE6F0FF),
          );
      } else if (key == 'unique') {
        return UniqueTab(
          favorites: favs,
          onToggleFavorite: (item) => _toggleFavorite(key, item),

        );
      } else if (key == 'community') {
        return CommunityTab( background: isDarkTheme ? Colors.blueGrey.shade100 : const Color(0xFFE6F0FF),);
      }
      return const SizedBox.shrink();
    }


    String _getSearchHint(String key) {
      switch (key) {
        case 'food': return 'Search food...';
        case 'exercise': return 'Search exercise...';
        case 'challenge': return 'Search is not available for challenges currently!';
        case 'unique': return 'Search is not available for quotes...';
        case 'community': return 'Search community...';
        default: return 'Search...';
      }
    }
  }

  // Info field container
  Widget _infoTile(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // Interactive drawer buttons
  Widget _drawerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showSettingsDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Settings"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.redAccent),
            title: const Text("Delete your account"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => _deleteAccountReasonDialog(context),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _deleteAccountReasonDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    bool isButtonEnabled = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Account"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please tell us why you're leaving:"),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter your reason here...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  setState(() {
                    isButtonEnabled = value.trim().isNotEmpty;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () async {
                final uid = FirebaseAuth.instance.currentUser!.uid;

                // Save the reason (optional)
                await FirebaseFirestore.instance
                    .collection('delete_requests')
                    .doc(uid)
                    .set({
                  'reason': reasonController.text.trim(),
                  'timestamp': Timestamp.now(),
                });

                // Delete user data
                await FirebaseFirestore.instance.collection('users').doc(uid).delete();

                // Delete the user account
                await FirebaseAuth.instance.currentUser!.delete();

                // Navigate to login screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const FancyWellBiteLogin()),
                      (route) => false,
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Delete My Account"),
            ),
          ],
        );
      },
    );
  }
