// lib/data/models/weather_model.dart
import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.countryCode,
    required super.flag,
    required super.temperature,
    required super.feelsLike,
    required super.tempMin,
    required super.tempMax,
    required super.humidity,
    required super.windSpeed,
    required super.pressure,
    required super.visibility,
    required super.condition,
    required super.conditionDesc,
    required super.lat,
    required super.lon,
    required super.sunrise,
    required super.sunset,
    required super.timezone,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String flag) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      countryCode: json['sys']?['country'] ?? '',
      flag: flag,
      temperature: (json['main']?['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']?['feels_like'] ?? 0).toDouble(),
      tempMin: (json['main']?['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']?['temp_max'] ?? 0).toDouble(),
      humidity: (json['main']?['humidity'] ?? 0).toInt(),
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
      pressure: (json['main']?['pressure'] ?? 0).toInt(),
      visibility: (json['visibility'] ?? 0).toInt(),
      condition: json['weather']?[0]?['main'] ?? 'Clear',
      conditionDesc: json['weather']?[0]?['description'] ?? '',
      lat: (json['coord']?['lat'] ?? 0).toDouble(),
      lon: (json['coord']?['lon'] ?? 0).toDouble(),
      sunrise: (json['sys']?['sunrise'] ?? 0).toInt(),
      sunset: (json['sys']?['sunset'] ?? 0).toInt(),
      timezone: (json['timezone'] ?? 0).toInt(),
    );
  }
}

// ─── MOCK DATA (fallback si API indisponible) ───────────────────────────────

const List<Map<String, dynamic>> mockWeatherData = [
  {
    'city': 'Dakar', 'flag': '🇸🇳',
    'temp': 28.0, 'feelsLike': 30.0, 'min': 24.0, 'max': 31.0,
    'humidity': 72, 'wind': 5.5, 'pressure': 1012, 'visibility': 9000,
    'condition': 'Clear', 'desc': 'ciel dégagé',
    'lat': 14.7167, 'lon': -17.4677, 'sunrise': 1709880000, 'sunset': 1709924000, 'tz': 0,
  },
  {
    'city': 'Paris', 'flag': '🇫🇷',
    'temp': 8.0, 'feelsLike': 5.0, 'min': 5.0, 'max': 11.0,
    'humidity': 78, 'wind': 4.2, 'pressure': 1018, 'visibility': 7000,
    'condition': 'Clouds', 'desc': 'nuageux',
    'lat': 48.8566, 'lon': 2.3522, 'sunrise': 1709867000, 'sunset': 1709909000, 'tz': 3600,
  },
  {
    'city': 'New York', 'flag': '🇺🇸',
    'temp': 4.0, 'feelsLike': 0.0, 'min': 1.0, 'max': 6.0,
    'humidity': 65, 'wind': 7.8, 'pressure': 1020, 'visibility': 10000,
    'condition': 'Rain', 'desc': 'pluie légère',
    'lat': 40.7128, 'lon': -74.0060, 'sunrise': 1709892000, 'sunset': 1709934000, 'tz': -18000,
  },
  {
    'city': 'Tokyo', 'flag': '🇯🇵',
    'temp': 12.0, 'feelsLike': 9.0, 'min': 8.0, 'max': 14.0,
    'humidity': 55, 'wind': 3.1, 'pressure': 1015, 'visibility': 10000,
    'condition': 'Clear', 'desc': 'ciel dégagé',
    'lat': 35.6762, 'lon': 139.6503, 'sunrise': 1709849000, 'sunset': 1709891000, 'tz': 32400,
  },
  {
    'city': 'London', 'flag': '🇬🇧',
    'temp': 10.0, 'feelsLike': 7.0, 'min': 7.0, 'max': 12.0,
    'humidity': 82, 'wind': 6.3, 'pressure': 1009, 'visibility': 5000,
    'condition': 'Rain', 'desc': 'bruine',
    'lat': 51.5074, 'lon': -0.1278, 'sunrise': 1709868000, 'sunset': 1709910000, 'tz': 0,
  },
];

WeatherModel mockFromData(Map<String, dynamic> d) => WeatherModel(
  cityName: d['city'], flag: d['flag'], countryCode: '',
  temperature: d['temp'], feelsLike: d['feelsLike'],
  tempMin: d['min'], tempMax: d['max'],
  humidity: d['humidity'], windSpeed: d['wind'],
  pressure: d['pressure'], visibility: d['visibility'],
  condition: d['condition'], conditionDesc: d['desc'],
  lat: d['lat'], lon: d['lon'],
  sunrise: d['sunrise'], sunset: d['sunset'], timezone: d['tz'],
);
