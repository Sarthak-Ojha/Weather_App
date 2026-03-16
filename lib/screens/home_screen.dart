import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';

/// HomeScreen is the main interface of the app
/// Contains search functionality and weather display
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  
  // Service instance for API calls
  final WeatherService _weatherService = WeatherService();
  
  // State variables
  WeatherModel? _weather;      // Stores fetched weather data
  List<ForecastModel>? _forecast; // Stores fetched forecast data
  bool _isLoading = false;      // Tracks loading state
  String? _errorMessage;        // Stores error messages

  @override
  void initState() {
    super.initState();
    // Fetch location-based weather on startup
    _getCurrentLocation();
  }

  /// Handles the search operation
  /// Fetches weather data and updates UI accordingly
  Future<void> _searchWeather() async {
    // Get city name from text field and trim whitespace
    final cityName = _searchController.text.trim();
    
    // Validate input
    if (cityName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    // Update UI to show loading state
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null;
      _forecast = null;
      // Clear focus to close keyboard
      FocusManager.instance.primaryFocus?.unfocus();
    });

    try {
      // Fetch weather data asynchronously
      final weather = await _weatherService.getWeather(cityName);
      final forecast = await _weatherService.getForecast(cityName);
      
      // Update UI with fetched data
      setState(() {
        _weather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// Fetches weather for the user's current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null;
      _forecast = null;
      _searchController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      } 

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      final weather = await _weatherService.getWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      final forecast = await _weatherService.getForecastByLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _weather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Abstract Modern Background - Blue and White Theme
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E88E5), // Light Blue
                  Color(0xFF1976D2), // Normal Blue
                  Color(0xFF1565C0), // Dark Blue
                ],
              ),
            ),
          ),
          
          // Decorative background circles
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlueAccent.withValues(alpha: 0.1),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar with Glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Search for a city...',
                            hintStyle: GoogleFonts.poppins(color: Colors.white60),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.search, color: Colors.white),
                                  onPressed: _searchWeather,
                                  tooltip: 'Search City',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.my_location, color: Colors.white),
                                  onPressed: _getCurrentLocation,
                                  tooltip: 'Current Location',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white54),
                                  onPressed: () => _searchController.clear(),
                                  tooltip: 'Clear Search',
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(
                              left: 20,
                              top: 18,
                              bottom: 18,
                            ),
                          ),
                          onSubmitted: (_) => _searchWeather(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Loading Indicator
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                color: Colors.red[100],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_weather != null && !_isLoading)
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: _buildWeatherCard()),
                          if (_forecast != null && _forecast!.isNotEmpty)
                            _buildForecastSection(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the weather information card widget with Glassmorphism
  Widget _buildWeatherCard() {
    return Center(
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // City Name
                Text(
                  _weather!.cityName,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Weather Icon
                Image.network(
                  _weather!.iconUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.cloud_outlined,
                      size: 80,
                      color: Colors.white70,
                    );
                  },
                ),
                
                // Temperature
                Text(
                  '${_weather!.temperature.toStringAsFixed(1)}°',
                  style: GoogleFonts.poppins(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),

                // Weather Description
                Text(
                  _weather!.description.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),

                // Divider
                Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                const SizedBox(height: 16),

                // Additional Info Row (Humidity & Wind Speed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Humidity
                    _buildInfoItem(
                      icon: Icons.water_drop_outlined,
                      label: 'Humidity',
                      value: '${_weather!.humidity}%',
                    ),
                    // Wind Speed
                    _buildInfoItem(
                      icon: Icons.air_outlined,
                      label: 'Wind',
                      value: '${_weather!.windSpeed.toStringAsFixed(1)} m/s',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  /// Builds the horizontal list for the 3-day forecast
  Widget _buildForecastSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _forecast!.length,
        itemBuilder: (context, index) {
          final daily = _forecast![index];
          // Format date to short week day (Mon, Tue, etc.)
          final dayName = DateFormat('E').format(daily.date);

          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        dayName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Image.network(
                        daily.iconUrl,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, _, __) => const Icon(
                          Icons.cloud_outlined,
                          color: Colors.white70,
                          size: 40,
                        ),
                      ),
                      Text(
                        '${daily.temperature.toStringAsFixed(0)}°',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Helper method to build info items (humidity/wind)
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}