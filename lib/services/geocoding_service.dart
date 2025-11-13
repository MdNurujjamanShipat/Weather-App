
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

class GeocodingService {
  static const String baseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  Future<List<Location>> searchLocation(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse('$baseUrl?name=$query&count=10&language=en&format=json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results.map((json) => Location.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to search location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search location: $e');
    }
  }
}