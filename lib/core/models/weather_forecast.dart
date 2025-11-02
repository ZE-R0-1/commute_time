/// 날씨 예보 정보
class WeatherForecast {
  final DateTime dateTime;
  final double temperature;
  final int humidity;
  final String precipitation;
  final String skyCondition;
  final String precipitationType;

  WeatherForecast({
    required this.dateTime,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.skyCondition,
    required this.precipitationType,
  });
}