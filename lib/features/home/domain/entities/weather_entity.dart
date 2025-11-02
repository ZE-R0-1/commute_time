import 'package:equatable/equatable.dart';

// 날씨 정보 Entity
class WeatherEntity extends Equatable {
  final double temperature;
  final int humidity;
  final String precipitation;
  final SkyCondition skyCondition;
  final PrecipitationType precipitationType;

  const WeatherEntity({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.skyCondition,
    required this.precipitationType,
  });

  @override
  List<Object?> get props => [
    temperature,
    humidity,
    precipitation,
    skyCondition,
    precipitationType,
  ];
}

// 날씨 예보 Entity
class WeatherForecastEntity extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final int humidity;
  final String precipitation;
  final SkyCondition skyCondition;
  final PrecipitationType precipitationType;

  const WeatherForecastEntity({
    required this.dateTime,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.skyCondition,
    required this.precipitationType,
  });

  @override
  List<Object?> get props => [
    dateTime,
    temperature,
    humidity,
    precipitation,
    skyCondition,
    precipitationType,
  ];
}

// 상세 비 예보 정보 Entity
class RainForecastEntity extends Equatable {
  final bool willRain;
  final DateTime? startTime;
  final DateTime? endTime;
  final String message;
  final String advice;
  final RainIntensity? intensity;

  const RainForecastEntity({
    required this.willRain,
    this.startTime,
    this.endTime,
    required this.message,
    required this.advice,
    this.intensity,
  });

  @override
  List<Object?> get props => [
    willRain,
    startTime,
    endTime,
    message,
    advice,
    intensity,
  ];
}

// 하늘 상태 enum
enum SkyCondition {
  clear,        // 맑음
  partlyCloudy, // 구름많음
  cloudy,       // 흐림
}

// 강수 형태 enum
enum PrecipitationType {
  none,           // 없음
  rain,           // 비
  rainSnow,       // 비/눈
  snow,           // 눈
  rainDrop,       // 빗방울
  rainSnowDrop,   // 빗방울눈날림
  snowDrop,       // 눈날림
}

// 비 강도 enum
enum RainIntensity {
  light,  // 약한 비
  heavy,  // 강한 비
}