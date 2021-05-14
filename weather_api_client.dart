import 'dart:convert';
import 'package:http/http.dart' as http;

import 'weather.dart';

class WeatherApiException implements Exception {
  WeatherApiException(this.message);
  final String message;
}

class WeatherApiClient {
  static const baseURL = 'https://www.metaweather.com/api';

  Future<int> getLocationID(String city) async {
    final locationURL = Uri.parse('$baseURL/location/search/?query=$city');
    final locationResponse = await http.get(locationURL);
    if (locationResponse.statusCode != 200) {
      throw WeatherApiException('Error getting locationID for city: $city');
    }
    final locationJson = jsonDecode(locationResponse.body) as List;
    if (locationJson.isEmpty) {
      throw WeatherApiException('No location found for city: $city');
    }
    return locationJson.first['woeid'] as int;
  }

  Future<Weather> fetchWeather(int locationID) async {
    final weatherURL = Uri.parse('$baseURL/location/$locationID');
    final weatherResponse = await http.get(weatherURL);
    if (weatherResponse.statusCode != 200) {
      throw WeatherApiException('Error getting weather for location: $locationID');
    }

    final weatherJson = jsonDecode(weatherResponse.body);
    final consolidatedWeather = weatherJson['consolidated_weather'] as List;
    if (consolidatedWeather.isEmpty) {
      throw WeatherApiException('Weather data not avaiable for locationID: $locationID');
    }
    return Weather.fromJson(consolidatedWeather[0]);
  }

  Future<Weather> getWeather(String city) async {
    final locationID = await getLocationID(city);
    return fetchWeather(locationID);
  }
}
