/// WeatherModel class represents the weather data structure
/// This model parses JSON data from OpenWeatherMap API
class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  /// Factory constructor to create WeatherModel from JSON
  /// Maps API response fields to our model properties
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      // Convert Kelvin to Celsius (API returns Kelvin by default)
      temperature: (json['main']['temp'] as num).toDouble() - 273.15,
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      // Wind speed is in m/s by default
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  /// Helper method to get full icon URL from OpenWeatherMap
  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}