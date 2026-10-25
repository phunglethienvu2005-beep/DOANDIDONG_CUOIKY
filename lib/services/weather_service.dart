import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {

  final String apiKey = "47edeb61b860b587e7922b709d7f6410";

  Future<Map<String, dynamic>> getWeather() async {

    // xin quyền location
    LocationPermission permission =
        await Geolocator.requestPermission();

    // lấy vị trí
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double lat = position.latitude;
    double lon = position.longitude;

    // gọi API
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return {
        "city": data["name"],
        "temp": data["main"]["temp"],
        "weather": data["weather"][0]["main"],
      };

    } else {
      throw Exception("Không lấy được thời tiết");
    }
  }
}