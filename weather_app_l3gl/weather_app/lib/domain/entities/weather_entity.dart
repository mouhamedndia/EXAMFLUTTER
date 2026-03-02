// lib/domain/entities/weather_entity.dart

class WeatherEntity {
  final String cityName;
  final String countryCode;
  final String flag;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final String condition;       // ex: "Clear", "Rain"
  final String conditionDesc;   // description en français
  final double lat;
  final double lon;
  final int sunrise;
  final int sunset;
  final int timezone;

  const WeatherEntity({
    required this.cityName,
    required this.countryCode,
    required this.flag,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.condition,
    required this.conditionDesc,
    required this.lat,
    required this.lon,
    required this.sunrise,
    required this.sunset,
    required this.timezone,
  });
}
