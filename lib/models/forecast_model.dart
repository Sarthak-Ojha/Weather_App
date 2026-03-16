/// ForecastModel represents a single weather forecast entry in the future.
/// Parses JSON from the OpenWeatherMap 5 day / 3 hour forecast API.
class ForecastModel {
  final DateTime date;
  final double temperature;
  final String description;
  final String iconCode;

  ForecastModel({
    required this.date,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      // The API provides dt as a unix timestamp (seconds), multiply by 1000 for DateTime
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      // Convert Kelvin to Celsius
      temperature: (json['main']['temp'] as num).toDouble() - 273.15,
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
    );
  }

  /// Helper method to get full icon URL from OpenWeatherMap
  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}
