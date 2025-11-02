/// 비 예보 정보
class RainForecastInfo {
  final bool willRain;
  final DateTime? startTime;
  final DateTime? endTime;
  final String message;
  final String advice;
  final String? intensity;

  RainForecastInfo({
    required this.willRain,
    this.startTime,
    this.endTime,
    required this.message,
    required this.advice,
    this.intensity,
  });
}