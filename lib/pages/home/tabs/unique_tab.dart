import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:wellbite/services/api_service.dart'; // Ensure this is imported properly

class UniqueTab extends StatefulWidget {
  final List<dynamic> favorites;
  final Function(dynamic) onToggleFavorite;

  const UniqueTab({
    Key? key,
    required this.favorites,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<UniqueTab> createState() => _UniqueTabState();
}

class _UniqueTabState extends State<UniqueTab> {
  bool isLoading = false;
  dynamic currentQuote;

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> fetchUniqueData() async {

    final uri = Uri.parse('https://api.api-ninjas.com/v1/quotes');
    final response = await http.get(uri, headers: {'X-Api-Key': "vOZWx7FEJsEjm/2iRW94TA==cPAjO7IHydcSHTRl"});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  }


  Future<void> fetchAndSetQuote() async {
    setState(() => isLoading = true);

    try {
      final results = await fetchUniqueData();
      if (results.isNotEmpty) {
        setState(() {
          currentQuote = results.first;
        });
      }
    } catch (e) {
      debugPrint('Error fetching quote: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SpinKitFadingCircle(color: Colors.teal, size: 50),
      );
    }

    if (currentQuote == null) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: fetchAndSetQuote,
          icon: const Icon(Icons.shuffle),
          label: const Text("Please press shuffle quote button to view quote"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      );
    }

    final isFavorite = widget.favorites.any((f) => f['quote'] == currentQuote['quote']);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '"${currentQuote['quote']}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "- ${currentQuote['author']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.grey,
                          ),
                          onPressed: () => widget.onToggleFavorite(currentQuote),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: fetchAndSetQuote,
                icon: const Icon(Icons.shuffle),
                label: const Text("Shuffle Quote"),
                style: ElevatedButton.styleFrom(
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadowColor: Colors.black26,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
