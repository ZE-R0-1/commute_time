/// 현재 날씨 정보
class WeatherInfo {
  final double temperature;
  final int humidity;
  final String precipitation;
  final String skyCondition;
  final String precipitationType;

  WeatherInfo({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.skyCondition,
    required this.precipitationType,
  });
}