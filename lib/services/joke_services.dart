import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jokes.dart';

class JokesService {
  final String _cacheKey = 'cached_jokes';

  Future<List<Joke>> fetchJokes({bool forceRefresh = false}) async {
    try {
      final response = await http.get(
        Uri.parse('https://official-joke-api.appspot.com/random_ten'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final jokes = jsonData.map((json) => Joke.fromJson(json)).toList();

        // Cache the jokes
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(
            jokes.map((joke) => joke.toJson()).toList()
        ));

        return jokes;
      } else {
        throw Exception('Failed to load jokes');
      }
    } catch (e) {
      // If there's an error, try to get cached jokes
      return getCachedJokes();
    }
  }

  Future<List<Joke>> getCachedJokes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKey);

      if (cachedData != null) {
        final List<dynamic> jsonData = json.decode(cachedData);
        return jsonData.map((json) => Joke.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error reading cache: $e');
    }
    return [];
  }
}