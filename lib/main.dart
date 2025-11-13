
import 'package:flutter/material.dart';
import 'screens/weather_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins',
        //fontFamily: 'Inter',
      ),
      home: const WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

