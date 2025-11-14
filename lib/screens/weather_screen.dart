import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/geocoding_service.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  final GeocodingService _geocodingService = GeocodingService();

  WeatherData? _weatherData;
  bool _isLoading = false;
  bool _isSearchingLocation = false;
  String _errorMessage = '';
  String _currentLocation = 'Dhaka, Bangladesh';
  List<Location> _searchResults = [];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchWeatherByCity('Dhaka');
  }

  Future<void> _fetchWeatherByCity(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _weatherData = null;
      _searchResults = [];
    });

    try {
      final locations = await _geocodingService.searchLocation(cityName);

      if (locations.isEmpty) {
        setState(() {
          _errorMessage = 'City not found. Please try another name.';
        });
        return;
      }

      final location = locations.first;

      // Show only city and country
      setState(() {
        _currentLocation = '${location.name}, ${location.country}';
      });

      final weatherData = await _weatherService.getWeatherData(
        location.latitude,
        location.longitude,
      );

      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isSearchingLocation = false;
      });
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearchingLocation = false;
      });
      return;
    }

    setState(() {
      _isSearchingLocation = true;
    });

    try {
      final locations = await _geocodingService.searchLocation(query);
      setState(() {
        _searchResults = locations;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearchingLocation = false;
      });
    }
  }

  void _onLocationSelected(Location location) {
    _cityController.text = location.name;
    setState(() {
      _searchResults = [];
    });
    _fetchWeatherByCity(location.name);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getBackgroundColor(),
              _getBackgroundColor().withOpacity(0.8),
              Colors.blueGrey.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Search Header
                _buildSearchHeader(),
                const SizedBox(height: 20),

                // Location Results
                if (_searchResults.isNotEmpty) _buildLocationResults(),

                // Content Area
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Column(
      children: [
        // Current Location
        Text(
          _currentLocation,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        // Search Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _cityController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: _searchLocations,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _fetchWeatherByCity(value);
                    }
                  },
                ),
              ),
              if (_cityController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _cityController.clear();
                    setState(() {
                      _searchResults = [];
                    });
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationResults() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (_isSearchingLocation)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            ..._searchResults
                .take(5)
                .map(
                  (location) => ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 20,
                    ),
                    title: Text(
                      location.name,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${location.name}, ${location.country}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => _onLocationSelected(location),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading Weather Data...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) {
      return Center(
        child: Text(
          'Search for a city to get weather forecast',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
        ),
      );
    }

    return _buildWeatherUI(_weatherData!);
  }

  Widget _buildWeatherUI(WeatherData weatherData) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Current Weather Section
          _buildCurrentWeather(weatherData),
          const SizedBox(height: 30),

          // Hourly Forecast
          _buildHourlyForecast(weatherData.hourly),
          const SizedBox(height: 30),

          // Daily Forecast
          _buildDailyForecast(weatherData.daily),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherData weatherData) {
    final current = weatherData.current;
    final today = weatherData.daily.isNotEmpty ? weatherData.daily.first : null;

    return Column(
      children: [
        // Weather Icon and Temperature
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedWeatherIcon(current.weatherCode, size: 120),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${current.temperature.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 0.9,
                  ),
                ),
                const SizedBox(height: 5),
                // High/Low for today
                if (today != null)
                  Row(
                    children: [
                      Text(
                        'H${today.temperatureMax.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'L${today.temperatureMin.toStringAsFixed(0)}°',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 5),
                Text(
                  _getWeatherDescription(current.weatherCode),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Weather Details
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(
                'Mixed conditions likely through today, Wind up to ${current.windSpeed.toStringAsFixed(0)} km/h.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherDetail(
                    'Wind',
                    '${current.windSpeed.toStringAsFixed(0)} km/h',
                  ),
                  _buildWeatherDetail(
                    'Humidity',
                    '${current.relativeHumidity}%',
                  ),
                  _buildWeatherDetail(
                    'Feels Like',
                    '${current.apparentTemperature.toStringAsFixed(0)}°',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(List<HourlyWeather> hourly) {
    final next12Hours = hourly.take(12).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'HOURLY FORECAST',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: next12Hours.length,
            itemBuilder: (context, index) {
              final hour = next12Hours[index];
              return Container(
                width: 80,
                margin: EdgeInsets.only(
                  right: index == next12Hours.length - 1 ? 0 : 12,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      _formatHour(hour.time),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    _buildAnimatedWeatherIcon(hour.weatherCode, size: 32),
                    Text(
                      '${hour.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast(List<DailyWeather> daily) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '10-DAY FORECAST',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: daily.take(10).map((day) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatDay(day.time),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildAnimatedWeatherIcon(
                        day.weatherCode,
                        size: 28,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${day.temperatureMax.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${day.temperatureMin.toStringAsFixed(0)}°',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedWeatherIcon(int weatherCode, {double size = 40}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: Icon(
        _getWeatherIcon(weatherCode),
        size: size,
        color: Colors.white,
      ),
    );
  }

  Widget _buildWeatherDetail(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(int weatherCode) {
    if (weatherCode == 0) {
      return Icons.wb_sunny;
    } else if (weatherCode == 1 || weatherCode == 2 || weatherCode == 3) {
      return Icons.cloud;
    } else if (weatherCode >= 45 && weatherCode <= 48) {
      return Icons.foggy;
    } else if (weatherCode >= 51 && weatherCode <= 67) {
      return Icons.grain;
    } else if (weatherCode >= 71 && weatherCode <= 77) {
      return Icons.ac_unit;
    } else if (weatherCode >= 80 && weatherCode <= 99) {
      return Icons.thunderstorm;
    } else {
      return Icons.help_outline;
    }
  }

  String _getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Sunny';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rainy';
      case 71:
      case 73:
      case 75:
        return 'Snowy';
      case 77:
        return 'Snow Grains';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 85:
      case 86:
        return 'Snow Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  Color _getBackgroundColor() {
    if (_weatherData == null) return Colors.blue.shade800;

    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) {
      return const Color(0xFF1A237E);
    } else {
      return const Color(0xFF0D47A1);
    }
  }

  String _formatHour(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day && time.hour == now.hour) return 'Now';
    return '${time.hour}:00';
  }

  String _formatDay(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (time.year == today.year &&
        time.month == today.month &&
        time.day == today.day) {
      return 'Today';
    } else if (time.year == tomorrow.year &&
        time.month == tomorrow.month &&
        time.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
