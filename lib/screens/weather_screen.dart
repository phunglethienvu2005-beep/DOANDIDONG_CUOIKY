import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService weatherService = WeatherService();

  String city = "";
  String weather = "";
  double temp = 0;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    final data = await weatherService.getWeather();

    setState(() {
      city = data["city"];
      weather = data["weather"];
      temp = data["temp"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$temp °C",
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            city,
            style: const TextStyle(fontSize: 24),
          ),

          Text(
            weather,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}