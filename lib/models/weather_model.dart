class WeatherData {
  final double latitude;
  final double longitude;
  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final hourly = json['hourly'];
    final daily = json['daily'];

    return WeatherData(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      current: CurrentWeather.fromJson(current),
      hourly: HourlyWeather.listFromJson(hourly),
      daily: DailyWeather.listFromJson(daily),
    );
  }
}

class CurrentWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final int relativeHumidity;
  final double apparentTemperature;

  CurrentWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.relativeHumidity,
    required this.apparentTemperature,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.parse(json['time']),
      temperature: json['temperature_2m']?.toDouble() ?? 0.0,
      weatherCode: json['weather_code'] ?? 0,
      windSpeed: json['wind_speed_10m']?.toDouble() ?? 0.0,
      relativeHumidity: json['relative_humidity_2m']?.toInt() ?? 0,
      apparentTemperature: json['apparent_temperature']?.toDouble() ?? 0.0,
    );
  }
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final double windSpeed;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
  });

  static List<HourlyWeather> listFromJson(Map<String, dynamic> json) {
    final times = json['time'] as List<dynamic>;
    final temperatures = json['temperature_2m'] as List<dynamic>;
    final weatherCodes = json['weather_code'] as List<dynamic>;
    final windSpeeds = json['wind_speed_10m'] as List<dynamic>;

    return List<HourlyWeather>.generate(
      times.length,
      (index) => HourlyWeather(
        time: DateTime.parse(times[index]),
        temperature: temperatures[index]?.toDouble() ?? 0.0,
        weatherCode: weatherCodes[index] ?? 0,
        windSpeed: windSpeeds[index]?.toDouble() ?? 0.0,
      ),
    );
  }
}

class DailyWeather {
  final DateTime time;
  final double temperatureMax;
  final double temperatureMin;
  final DateTime sunrise;
  final DateTime sunset;
  final int weatherCode;

  DailyWeather({
    required this.time,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.sunrise,
    required this.sunset,
    required this.weatherCode,
  });

  static List<DailyWeather> listFromJson(Map<String, dynamic> json) {
    final times = json['time'] as List<dynamic>;
    final tempMax = json['temperature_2m_max'] as List<dynamic>;
    final tempMin = json['temperature_2m_min'] as List<dynamic>;
    final sunrises = json['sunrise'] as List<dynamic>;
    final sunsets = json['sunset'] as List<dynamic>;
    final weatherCodes = json['weather_code'] as List<dynamic>;

    return List<DailyWeather>.generate(
      times.length,
      (index) => DailyWeather(
        time: DateTime.parse(times[index]),
        temperatureMax: tempMax[index]?.toDouble() ?? 0.0,
        temperatureMin: tempMin[index]?.toDouble() ?? 0.0,
        sunrise: DateTime.parse(sunrises[index]),
        sunset: DateTime.parse(sunsets[index]),
        weatherCode: weatherCodes[index] ?? 0,
      ),
    );
  }
}


