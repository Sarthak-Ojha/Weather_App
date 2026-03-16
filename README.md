# Weather App 🌤️

A beautifully designed, modern Weather Application built with **Flutter**. This app provides real-time weather information and a 3-day forecast for any city worldwide, utilizing the OpenWeatherMap API. 

## Features
- **Real-Time Weather:** Get accurate and current weather conditions (temperature, humidity, wind speed) for your specified city.
- **Location-based Weather:** Instantly fetch weather for your device's current location via GPS.
- **3-Day Forecast:** View the upcoming 3-day forecast to plan your week ahead.
- **Modern Interface:** A sleek blue-and-white theme featuring dynamic glassmorphism aesthetics.
![Image Alt](image_url)
![Image Alt](image_url)
## Setting Up the Project

Because this app relies on the OpenWeatherMap network, you will need to apply for your own free API key and supply it in the code before running the application.

### 1. Get an API Key
1. Go to [OpenWeatherMap](https://openweathermap.org/) and create a free account.
2. Navigate to your dashboard and generate a new API key.

### 2. Configure the Project
To run this project on your local machine, clone the repository, and update the API key.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Sarthak-Ojha/Weather-_App.git
   cd Weather-_App
   ```

2. **Add your API Key:**
   Open `lib/services/weather_service.dart` and locate the `_apiKey` variable at the top of the `WeatherService` class.
   
   Replace `'YOUR_API_KEY_HERE'` with the actual key you generated from OpenWeatherMap:
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```

3. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

## Dependencies
- `http`: For making HTTP network requests to OpenWeatherMap.
- `geolocator`: For fetching user's current geographic location.
- `google_fonts`: For beautiful modern typography.
- `intl`: For parsing and formatting 날짜 date objects.

## License
This project is open-source and available under the MIT License.
