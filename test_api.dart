import 'package:flutter/foundation.dart';
import 'package:weather_app/services/weather_service.dart';

void main() async {
  final service = WeatherService();
  try {
    final weather = await service.getWeather('London');
    debugPrint('Success: ${weather.cityName}, ${weather.temperature}');
  } catch (e) {
    debugPrint('Failed: $e');
  }
}
