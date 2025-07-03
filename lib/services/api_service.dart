import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey;

  ApiService({required this.apiKey});

  Future<List<dynamic>> fetchNutritionData(String query) async {
    if (query.isEmpty) return [];
    final uri = Uri.parse('https://api.api-ninjas.com/v1/nutrition?query=$query');
    final response = await http.get(uri, headers: {'X-Api-Key': apiKey});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchExerciseData(String query) async {
    // Use 'query=query' on initial/default load
    if (query.isEmpty) {
      final uri = Uri.parse('https://api.api-ninjas.com/v1/exercises?query=query');
      final response = await http.get(uri, headers: {'X-Api-Key': apiKey});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    }

    // Lowercase the query to match conditions
    final lowerQuery = query.toLowerCase();

    const List<String> types = [
      'cardio',
      'olympic_weightlifting',
      'plyometrics',
      'powerlifting',
      'strength',
      'stretching',
      'strongman',
    ];

    const List<String> muscles = [
      'abdominals',
      'abductors',
      'adductors',
      'biceps',
      'calves',
      'chest',
      'forearms',
      'glutes',
      'hamstrings',
      'lats',
      'lower_back',
      'middle_back',
      'neck',
      'quadriceps',
      'traps',
      'triceps',
    ];

    const List<String> difficulties = [
      'beginner',
      'intermediate',
      'expert',
    ];

    String param;

    if (types.contains(lowerQuery)) {
      param = 'type=$lowerQuery';
    } else if (muscles.contains(lowerQuery)) {
      param = 'muscle=$lowerQuery';
    } else if (difficulties.contains(lowerQuery)) {
      param = 'difficulty=$lowerQuery';
    } else {
      param = 'name=$lowerQuery';
    }

    final uri = Uri.parse('https://api.api-ninjas.com/v1/exercises?$param');
    final response = await http.get(uri, headers: {'X-Api-Key': apiKey});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  }



}
