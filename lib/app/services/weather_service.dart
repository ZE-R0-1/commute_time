// lib/app/services/weather_service.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  static final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  static final String _baseUrl = dotenv.env['WEATHER_API_URL'] ?? '';

  // 기상청 격자 좌표 변환 (위도/경도 → 격자 X,Y)
  static Map<String, int> _convertToGrid(double lat, double lon) {
    // 기상청 좌표계 변환 공식
    const double RE = 6371.00877; // 지구 반지름
    const double GRID = 5.0; // 격자 간격 (km)
    const double SLAT1 = 30.0; // 투영 위도1
    const double SLAT2 = 60.0; // 투영 위도2
    const double OLON = 126.0; // 기준점 경도
    const double OLAT = 38.0; // 기준점 위도
    const double XO = 43; // 기준점 X좌표
    const double YO = 136; // 기준점 Y좌표

    const double DEGRAD = math.pi / 180.0;
    const double re = RE / GRID;
    const double slat1 = SLAT1 * DEGRAD;
    const double slat2 = SLAT2 * DEGRAD;
    const double olon = OLON * DEGRAD;
    const double olat = OLAT * DEGRAD;

    double sn = (math.log(math.cos(slat1) / math.cos(slat2)) /
        math.log(math.tan(math.pi / 4.0 + slat2 / 2.0) /
            math.tan(math.pi / 4.0 + slat1 / 2.0)));
    double sf = math.pow(math.tan(math.pi / 4.0 + slat1 / 2.0), sn) *
        math.cos(slat1) / sn;
    double ro = re * sf / math.pow(math.tan(math.pi / 4.0 + olat / 2.0), sn);

    double ra = re * sf / math.pow(math.tan(math.pi / 4.0 + lat * DEGRAD / 2.0), sn);
    double theta = lon * DEGRAD - olon;
    if (theta > math.pi) theta -= 2.0 * math.pi;
    if (theta < -math.pi) theta += 2.0 * math.pi;
    theta *= sn;

    int x = (ra * math.sin(theta) + XO + 0.5).floor();
    int y = (ro - ra * math.cos(theta) + YO + 0.5).floor();

    return {'x': x, 'y': y};
  }

  // 현재 날씨 정보 조회 (초단기실황)
  static Future<WeatherInfo?> getCurrentWeather(double lat, double lon) async {
    try {
      final grid = _convertToGrid(lat, lon);
      final now = DateTime.now();

      // 기상청 API는 40분 단위로 업데이트
      final baseTime = _getBaseTime(now);
      final baseDate = _formatDate(now);

      final url = Uri.parse('$_baseUrl/getUltraSrtNcst').replace(queryParameters: {
        'serviceKey': _apiKey,
        'pageNo': '1',
        'numOfRows': '10',
        'dataType': 'JSON',
        'base_date': baseDate,
        'base_time': baseTime,
        'nx': grid['x'].toString(),
        'ny': grid['y'].toString(),
      });

      print('날씨 API 호출: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseCurrentWeather(data);
      } else {
        print('날씨 API 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('날씨 정보 조회 오류: $e');
      return null;
    }
  }

  // 단기예보 조회 (3일치)
  static Future<List<WeatherForecast>> getWeatherForecast(double lat, double lon) async {
    try {
      final grid = _convertToGrid(lat, lon);
      final now = DateTime.now();

      // 단기예보는 2,5,8,11,14,17,20,23시에 발표
      final baseTime = _getForecastBaseTime(now);
      final baseDate = _formatDate(now);

      final url = Uri.parse('$_baseUrl/getVilageFcst').replace(queryParameters: {
        'serviceKey': _apiKey,
        'pageNo': '1',
        'numOfRows': '300',
        'dataType': 'JSON',
        'base_date': baseDate,
        'base_time': baseTime,
        'nx': grid['x'].toString(),
        'ny': grid['y'].toString(),
      });

      print('날씨 예보 API 호출: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // API 응답이 XML인지 JSON인지 확인
        final responseBody = response.body;
        if (responseBody.trim().startsWith('<')) {
          print('날씨 예보 API가 XML로 응답: ${responseBody.substring(0, 100)}...');
          return [];
        }
        
        final data = json.decode(responseBody);
        return _parseWeatherForecast(data);
      } else {
        print('날씨 예보 API 오류: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('날씨 예보 조회 오류: $e');
      return [];
    }
  }

  // 🆕 오늘의 상세 비 예보 분석
  static RainForecastInfo? analyzeTodayRainForecast(List<WeatherForecast> forecasts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 오늘 예보만 필터링
    final todayForecasts = forecasts.where((forecast) =>
    forecast.dateTime.year == today.year &&
        forecast.dateTime.month == today.month &&
        forecast.dateTime.day == today.day &&
        forecast.dateTime.isAfter(now) // 현재 시간 이후만
    ).toList();

    if (todayForecasts.isEmpty) return null;

    // 비가 오는 시간대 찾기
    List<WeatherForecast> rainForecasts = todayForecasts.where((forecast) =>
    forecast.precipitationType == PrecipitationType.rain ||
        forecast.precipitationType == PrecipitationType.rainDrop ||
        forecast.precipitationType == PrecipitationType.rainSnow ||
        forecast.precipitationType == PrecipitationType.rainSnowDrop
    ).toList();

    if (rainForecasts.isEmpty) {
      return RainForecastInfo(
        willRain: false,
        message: '오늘은 비 소식이 없어요',
        advice: '쾌적한 하루 되세요!',
      );
    }

    // 첫 번째 비 시작 시간
    final firstRain = rainForecasts.first;
    final startTime = firstRain.dateTime;

    // 비가 끝나는 시간 (연속되지 않는 첫 번째 시점)
    DateTime? endTime;
    for (int i = 0; i < todayForecasts.length - 1; i++) {
      final current = todayForecasts[i];
      final next = todayForecasts[i + 1];

      // 현재는 비, 다음은 비 아님
      if (_isRaining(current) && !_isRaining(next)) {
        endTime = next.dateTime;
        break;
      }
    }

    return RainForecastInfo(
      willRain: true,
      startTime: startTime,
      endTime: endTime,
      message: _generateRainMessage(startTime, endTime, now),
      advice: _generateRainAdvice(startTime, now),
      intensity: _getRainIntensity(rainForecasts),
    );
  }

  // 🆕 비 오는지 확인 헬퍼 함수
  static bool _isRaining(WeatherForecast forecast) {
    return forecast.precipitationType == PrecipitationType.rain ||
        forecast.precipitationType == PrecipitationType.rainDrop ||
        forecast.precipitationType == PrecipitationType.rainSnow ||
        forecast.precipitationType == PrecipitationType.rainSnowDrop;
  }

  // 🆕 비 예보 메시지 생성
  static String _generateRainMessage(DateTime startTime, DateTime? endTime, DateTime now) {
    final hour = startTime.hour;
    final minute = startTime.minute;

    String timeMessage;
    if (hour < 12) {
      timeMessage = '오전 ${hour}시';
    } else if (hour == 12) {
      timeMessage = '정오';
    } else if (hour < 18) {
      timeMessage = '오후 ${hour - 12}시';
    } else {
      timeMessage = '저녁 ${hour - 12}시';
    }

    if (minute > 0) {
      timeMessage += ' ${minute}분';
    }

    String durationMessage = '';
    if (endTime != null) {
      final duration = endTime.difference(startTime).inHours;
      if (duration > 0) {
        durationMessage = ' (약 ${duration}시간)';
      }
    }

    return '🌧️ ${timeMessage}부터 비 예보$durationMessage';
  }

  // 🆕 비 예보 조언 생성
  static String _generateRainAdvice(DateTime startTime, DateTime now) {
    final hoursUntilRain = startTime.difference(now).inHours;

    if (hoursUntilRain <= 1) {
      return '곧 비가 시작돼요! 우산을 미리 준비하세요';
    } else if (hoursUntilRain <= 3) {
      return '우산을 챙기시고 일찍 출발하는 것을 권장드려요';
    } else if (hoursUntilRain <= 6) {
      return '오늘은 우산을 꼭 챙겨주세요';
    } else {
      return '나중에 비가 올 예정이니 우산을 준비해두세요';
    }
  }

  // 🆕 비 강도 분석
  static RainIntensity _getRainIntensity(List<WeatherForecast> rainForecasts) {
    // 강수량 평균 계산 (임시로 간단한 로직)
    final hasHeavyRain = rainForecasts.any((forecast) =>
    forecast.precipitation != '0' &&
        forecast.precipitation.contains('mm') &&
        double.tryParse(forecast.precipitation.replaceAll('mm', '')) != null &&
        double.parse(forecast.precipitation.replaceAll('mm', '')) > 5.0
    );

    if (hasHeavyRain) {
      return RainIntensity.heavy;
    } else {
      return RainIntensity.light;
    }
  }

  // 기준 시간 계산 (초단기실황)
  static String _getBaseTime(DateTime now) {
    final hour = now.hour;
    final minute = now.minute;

    // 40분 단위 업데이트, 10분 후 데이터 제공
    if (minute < 10) {
      // 이전 시간 데이터 사용
      final prevHour = hour == 0 ? 23 : hour - 1;
      return prevHour.toString().padLeft(2, '0') + '00';
    } else {
      return hour.toString().padLeft(2, '0') + '00';
    }
  }

  // 예보 기준 시간 계산 (단기예보)
  static String _getForecastBaseTime(DateTime now) {
    final hour = now.hour;

    // 2,5,8,11,14,17,20,23시 발표
    const List<int> baseTimes = [2, 5, 8, 11, 14, 17, 20, 23];

    int baseHour = 23; // 기본값: 전날 23시
    for (int time in baseTimes) {
      if (hour >= time) {
        baseHour = time;
      }
    }

    return baseHour.toString().padLeft(2, '0') + '00';
  }

  // 날짜 포맷 (YYYYMMDD)
  static String _formatDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  // 현재 날씨 데이터 파싱
  static WeatherInfo? _parseCurrentWeather(Map<String, dynamic> data) {
    try {
      final items = data['response']['body']['items']['item'] as List;

      Map<String, String> weatherData = {};
      for (var item in items) {
        weatherData[item['category']] = item['obsrValue'];
      }

      return WeatherInfo(
        temperature: double.tryParse(weatherData['T1H'] ?? '0') ?? 0,
        humidity: int.tryParse(weatherData['REH'] ?? '0') ?? 0,
        precipitation: weatherData['RN1'] ?? '0',
        skyCondition: _getSkyCondition(weatherData['SKY'] ?? '1'),
        precipitationType: _getPrecipitationType(weatherData['PTY'] ?? '0'),
      );
    } catch (e) {
      print('날씨 데이터 파싱 오류: $e');
      return null;
    }
  }

  // 예보 데이터 파싱
  static List<WeatherForecast> _parseWeatherForecast(Map<String, dynamic> data) {
    try {
      final items = data['response']['body']['items']['item'] as List;
      Map<String, Map<String, String>> forecastData = {};

      // 시간별로 데이터 그룹화
      for (var item in items) {
        final dateTime = '${item['fcstDate']}_${item['fcstTime']}';
        forecastData[dateTime] ??= {};
        forecastData[dateTime]![item['category']] = item['fcstValue'];
      }

      List<WeatherForecast> forecasts = [];
      forecastData.forEach((dateTime, data) {
        final parts = dateTime.split('_');
        final date = parts[0];
        final time = parts[1];

        final forecastDateTime = DateTime(
          int.parse(date.substring(0, 4)),
          int.parse(date.substring(4, 6)),
          int.parse(date.substring(6, 8)),
          int.parse(time.substring(0, 2)),
        );


        forecasts.add(WeatherForecast(
          dateTime: forecastDateTime,
          temperature: double.tryParse(data['TMP'] ?? '0') ?? 0,
          humidity: int.tryParse(data['REH'] ?? '0') ?? 0,
          precipitation: data['PCP'] ?? '0',
          skyCondition: _getSkyCondition(data['SKY'] ?? '1'),
          precipitationType: _getPrecipitationType(data['PTY'] ?? '0'),
        ));
      });

      // 시간순 정렬
      forecasts.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      return forecasts;
    } catch (e) {
      print('날씨 예보 파싱 오류: $e');
      return [];
    }
  }

  // 하늘 상태 변환
  static SkyCondition _getSkyCondition(String code) {
    switch (code) {
      case '1': return SkyCondition.clear;
      case '3': return SkyCondition.partlyCloudy;
      case '4': return SkyCondition.cloudy;
      default: return SkyCondition.clear;
    }
  }

  // 강수 형태 변환
  static PrecipitationType _getPrecipitationType(String code) {
    switch (code) {
      case '0': return PrecipitationType.none;
      case '1': return PrecipitationType.rain;
      case '2': return PrecipitationType.rainSnow;
      case '3': return PrecipitationType.snow;
      case '5': return PrecipitationType.rainDrop;
      case '6': return PrecipitationType.rainSnowDrop;
      case '7': return PrecipitationType.snowDrop;
      default: return PrecipitationType.none;
    }
  }
}

// 🆕 상세 비 예보 정보 모델
class RainForecastInfo {
  final bool willRain;
  final DateTime? startTime;
  final DateTime? endTime;
  final String message;
  final String advice;
  final RainIntensity? intensity;

  RainForecastInfo({
    required this.willRain,
    this.startTime,
    this.endTime,
    required this.message,
    required this.advice,
    this.intensity,
  });
}

// 🆕 비 강도 enum
enum RainIntensity {
  light,   // 약한 비
  heavy,   // 강한 비
}

// 날씨 정보 모델
class WeatherInfo {
  final double temperature; // 기온
  final int humidity; // 습도
  final String precipitation; // 강수량
  final SkyCondition skyCondition; // 하늘 상태
  final PrecipitationType precipitationType; // 강수 형태

  WeatherInfo({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.skyCondition,
    required this.precipitationType,
  });

  String get weatherDescription {
    switch (skyCondition) {
      case SkyCondition.clear:
        return '맑음';
      case SkyCondition.partlyCloudy:
        return '구름많음';
      case SkyCondition.cloudy:
        return '흐림';
    }
  }

}

// 날씨 예보 모델
class WeatherForecast {
  final DateTime dateTime;
  final double temperature;
  final int humidity;
  final String precipitation;
  final SkyCondition skyCondition;
  final PrecipitationType precipitationType;

  WeatherForecast({
    required this.dateTime,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.skyCondition,
    required this.precipitationType,
  });
}

// 하늘 상태 enum
enum SkyCondition {
  clear, // 맑음
  partlyCloudy, // 구름많음
  cloudy, // 흐림
}

// 강수 형태 enum
enum PrecipitationType {
  none, // 없음
  rain, // 비
  rainSnow, // 비/눈
  snow, // 눈
  rainDrop, // 빗방울
  rainSnowDrop, // 빗방울눈날림
  snowDrop, // 눈날림
}