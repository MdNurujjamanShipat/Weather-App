import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String timezone = 'Asia/Dhaka';

  Future<WeatherData> getWeatherData(double latitude, double longitude) async {
    final url = Uri.parse(
      '$baseUrl?'
      'latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m,apparent_temperature'
      '&hourly=temperature_2m,weather_code,wind_speed_10m'
      '&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,weather_code'
      '&forecast_days=10'
      '&timezone=Asia%2FDhaka',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }
}


