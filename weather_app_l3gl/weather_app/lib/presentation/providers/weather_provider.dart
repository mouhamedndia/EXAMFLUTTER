// lib/presentation/providers/weather_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/repositories/weather_repository.dart';
import '../../domain/entities/weather_entity.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _repo = WeatherRepository();

  WeatherStatus _status = WeatherStatus.initial;
  List<WeatherEntity> _cities = [];
  List<WeatherEntity> _loadedCities = [];
  String _errorMessage = '';
  int _loadedCount = 0;
  int _totalCount = WeatherRepository.cities.length;
  ThemeMode _themeMode = ThemeMode.dark;

  // ── Getters ──────────────────────────────────────
  WeatherStatus get status => _status;
  List<WeatherEntity> get cities => _cities;
  List<WeatherEntity> get loadedCities => _loadedCities;
  String get errorMessage => _errorMessage;
  int get loadedCount => _loadedCount;
  int get totalCount => _totalCount;
  double get progress => _totalCount == 0 ? 0 : _loadedCount / _totalCount;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // ── Chargement ───────────────────────────────────
  Future<void> loadWeather() async {
    _status = WeatherStatus.loading;
    _loadedCount = 0;
    _loadedCities = [];
    _cities = [];
    _errorMessage = '';
    notifyListeners();

    try {
      _cities = await _repo.fetchAll(
        onProgress: (done, total, city) {
          _loadedCount = done;
          _totalCount = total;
          _loadedCities = [..._loadedCities, city];
          notifyListeners();
        },
      );
      _status = WeatherStatus.loaded;
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = 'Erreur de chargement : $e';
    }
    notifyListeners();
  }

  void reset() {
    _status = WeatherStatus.initial;
    _cities = [];
    _loadedCities = [];
    _loadedCount = 0;
    notifyListeners();
  }
}

// ── ThemeProvider ────────────────────────────────────────────────────────────

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
