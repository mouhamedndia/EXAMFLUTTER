// lib/data/repositories/weather_repository.dart
import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../../domain/entities/weather_entity.dart';

class WeatherRepository {
  static const _apiKey = '962cd6ae3cf04ca03526b9efbfc39432';
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  final Dio _dio;

  WeatherRepository()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Liste des 5 villes avec drapeaux
  static const cities = [
    {'name': 'Dakar', 'flag': '🇸🇳'},
    {'name': 'Paris', 'flag': '🇫🇷'},
    {'name': 'New York', 'flag': '🇺🇸'},
    {'name': 'Tokyo', 'flag': '🇯🇵'},
    {'name': 'London', 'flag': '🇬🇧'},
  ];

  /// Récupère la météo d'une ville
  Future<WeatherEntity> fetchCity(String cityName, String flag) async {
    try {
      final res = await _dio.get(_baseUrl, queryParameters: {
        'q': cityName,
        'appid': _apiKey,
        'units': 'metric',
        'lang': 'fr',
      });
      return WeatherModel.fromJson(res.data, flag);
    } catch (_) {
      // Fallback mock
      final mock = mockWeatherData.firstWhere(
        (m) => (m['city'] as String).toLowerCase() == cityName.toLowerCase(),
        orElse: () => mockWeatherData[0],
      );
      return mockFromData(mock);
    }
  }

  /// Récupère toutes les villes avec callback de progression
  Future<List<WeatherEntity>> fetchAll({
    void Function(int done, int total, WeatherEntity city)? onProgress,
  }) async {
    final results = <WeatherEntity>[];
    for (int i = 0; i < cities.length; i++) {
      final city = cities[i];
      final weather = await fetchCity(city['name']!, city['flag']!);
      results.add(weather);
      onProgress?.call(i + 1, cities.length, weather);
      // Délai entre les appels pour simuler la progression
      await Future.delayed(const Duration(milliseconds: 800));
    }
    return results;
  }
}
