import '../../domain/entities/weather_entity.dart';

// 날씨 응답 모델
class WeatherResponse {
  final double temperature;
  final int humidity;
  final String precipitation;
  final String skyCondition;
  final String precipitationType;

  WeatherResponse({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.skyCondition,
    required this.precipitationType,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final temperature = json['temperature'];
    final humidity = json['humidity'];

    double temperatureValue = (temperature is double) ? temperature : ((temperature is int) ? temperature.toDouble() : double.parse(temperature.toString()));
    int humidityValue = (humidity is int) ? humidity : int.parse(humidity.toString());

    return WeatherResponse(
      temperature: temperatureValue,
      humidity: humidityValue,
      precipitation: json['precipitation'] as String? ?? '0',
      skyCondition: json['skyCondition'] as String? ?? '1',
      precipitationType: json['precipitationType'] as String? ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'humidity': humidity,
    'precipitation': precipitation,
    'skyCondition': skyCondition,
    'precipitationType': precipitationType,
  };

  // Entity로 변환
  WeatherEntity toEntity() {
    return WeatherEntity(
      temperature: temperature,
      humidity: humidity,
      precipitation: precipitation,
      skyCondition: _parseSkyCondition(skyCondition),
      precipitationType: _parsePrecipitationType(precipitationType),
    );
  }

  static SkyCondition _parseSkyCondition(String code) {
    switch (code) {
      case '1':
        return SkyCondition.clear;
      case '3':
        return SkyCondition.partlyCloudy;
      case '4':
        return SkyCondition.cloudy;
      default:
        return SkyCondition.clear;
    }
  }

  static PrecipitationType _parsePrecipitationType(String code) {
    switch (code) {
      case '0':
        return PrecipitationType.none;
      case '1':
        return PrecipitationType.rain;
      case '2':
        return PrecipitationType.rainSnow;
      case '3':
        return PrecipitationType.snow;
      case '5':
        return PrecipitationType.rainDrop;
      case '6':
        return PrecipitationType.rainSnowDrop;
      case '7':
        return PrecipitationType.snowDrop;
      default:
        return PrecipitationType.none;
    }
  }
}

// 날씨 예보 응답 모델
class WeatherForecastResponse {
  final DateTime dateTime;
  final double temperature;
  final int humidity;
  final String precipitation;
  final String skyCondition;
  final String precipitationType;

  WeatherForecastResponse({
    required this.dateTime,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.skyCondition,
    required this.precipitationType,
  });

  factory WeatherForecastResponse.fromJson(Map<String, dynamic> json) {
    final temperature = json['temperature'];
    final humidity = json['humidity'];
    final dateTime = json['dateTime'];

    double temperatureValue = (temperature is double) ? temperature : ((temperature is int) ? temperature.toDouble() : double.parse(temperature.toString()));
    int humidityValue = (humidity is int) ? humidity : int.parse(humidity.toString());
    DateTime dateTimeValue = dateTime is DateTime ? dateTime : DateTime.parse(dateTime.toString());

    return WeatherForecastResponse(
      dateTime: dateTimeValue,
      temperature: temperatureValue,
      humidity: humidityValue,
      precipitation: json['precipitation'] as String? ?? '0',
      skyCondition: json['skyCondition'] as String? ?? '1',
      precipitationType: json['precipitationType'] as String? ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    'temperature': temperature,
    'humidity': humidity,
    'precipitation': precipitation,
    'skyCondition': skyCondition,
    'precipitationType': precipitationType,
  };

  // Entity로 변환
  WeatherForecastEntity toEntity() {
    return WeatherForecastEntity(
      dateTime: dateTime,
      temperature: temperature,
      humidity: humidity,
      precipitation: precipitation,
      skyCondition: WeatherResponse._parseSkyCondition(skyCondition),
      precipitationType: WeatherResponse._parsePrecipitationType(precipitationType),
    );
  }
}