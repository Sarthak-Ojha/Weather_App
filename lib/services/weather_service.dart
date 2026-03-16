import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

/// WeatherService handles all API communication with OpenWeatherMap
/// Uses async/await for asynchronous HTTP requests
class WeatherService {
  // Base URLs for OpenWeatherMap API
  static const String _weatherUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String _forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';
  
  // API Key - Replace with your actual API key from OpenWeatherMap
  static const String _apiKey = '56409f4727edc2b24fff60681e0ee7ff';

  /// Fetches current weather data for a specific city
  /// Returns WeatherModel on success, throws exception on failure
  Future<WeatherModel> getWeather(String cityName) async {
    try {
      // Construct URL with query parameters
      final url = Uri.parse('$_weatherUrl?q=$cityName&appid=$_apiKey');
      
      return await _fetchData(url);
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  /// Fetches weather data based on geographic coordinates
  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    try {
      // Construct URL with latitude and longitude parameters
      final url = Uri.parse('$_weatherUrl?lat=$lat&lon=$lon&appid=$_apiKey');
      
      return await _fetchData(url);
    } catch (e) {
      throw Exception('Error fetching weather by location: $e');
    }
  }

  /// Fetches 3-day forecast data for a specific city
  Future<List<ForecastModel>> getForecast(String cityName) async {
    try {
      final url = Uri.parse('$_forecastUrl?q=$cityName&appid=$_apiKey');
      return await _fetchForecastData(url);
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  /// Fetches 3-day forecast data based on geographic coordinates
  Future<List<ForecastModel>> getForecastByLocation(double lat, double lon) async {
    try {
      final url = Uri.parse('$_forecastUrl?lat=$lat&lon=$lon&appid=$_apiKey');
      return await _fetchForecastData(url);
    } catch (e) {
      throw Exception('Error fetching forecast by location: $e');
    }
  }

  /// Helper method to make the HTTP request and parse response
  Future<WeatherModel> _fetchData(Uri url) async {
    // Make HTTP GET request
    final response = await http.get(url);

    // Check response status code
    if (response.statusCode == 200) {
      // Parse JSON response
      final jsonData = jsonDecode(response.body);
      return WeatherModel.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      // City not found
      throw Exception('Location not found.');
    } else {
      // Other API errors
      throw Exception('Failed to load weather data. Status: ${response.statusCode}');
    }
  }

  /// Helper method to fetch and parse forecast list
  /// Filters the 3-hour interval data to return one forecast per day for the next 3 distinct days
  Future<List<ForecastModel>> _fetchForecastData(Uri url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> list = jsonData['list'];

      // Parse all forecasts
      final allForecasts = list.map((item) => ForecastModel.fromJson(item)).toList();

      // Filter logic: We want 3 distinct days from the future.
      // The API returns data every 3 hours. We'll pick the forecast around noon (12:00) 
      // or the closest available block for each day.
      final Map<String, ForecastModel> dailyForecasts = {};
      final now = DateTime.now();

      for (var forecast in allForecasts) {
        // Skip today
        if (forecast.date.day == now.day && forecast.date.month == now.month) {
          continue;
        }

        // Use a simple yyyy-mm-dd key
        final dateKey = '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';
        
        // If we haven't stored a forecast for this day yet, or if this forecast is closer to noon (12 PM)
        if (!dailyForecasts.containsKey(dateKey)) {
          dailyForecasts[dateKey] = forecast;
        } else {
          // Improve selection: try to get the forecast closest to 12:00 PM local time
          final currentBest = dailyForecasts[dateKey]!;
          final hoursDiffTarget = (forecast.date.hour - 12).abs();
          final currentBestHoursDiff = (currentBest.date.hour - 12).abs();
          
          if (hoursDiffTarget < currentBestHoursDiff) {
            dailyForecasts[dateKey] = forecast;
          }
        }

        // We only want 3 days max
        if (dailyForecasts.length >= 3) {
          break;
        }
      }

      // Return as a sorted list
      final sortedList = dailyForecasts.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return sortedList;

    } else if (response.statusCode == 404) {
      throw Exception('Location not found.');
    } else {
      throw Exception('Failed to load forecast data. Status: ${response.statusCode}');
    }
  }
}