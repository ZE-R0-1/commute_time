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
        'numOfRows': '100', // 3일치 데이터
        'dataType': 'JSON',
        'base_date': baseDate,
        'base_time': baseTime,
        'nx': grid['x'].toString(),
        'ny': grid['y'].toString(),
      });

      print('날씨 예보 API 호출: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
        windSpeed: double.tryParse(weatherData['WSD'] ?? '0') ?? 0,
        skyCondition: _getSkyCondition(weatherData['SKY'] ?? '1'),
        precipitationType: _getPrecipitationType(weatherData['PTY'] ?? '0'),
        updateTime: DateTime.now(),
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
          maxTemperature: double.tryParse(data['TMX'] ?? '0'),
          minTemperature: double.tryParse(data['TMN'] ?? '0'),
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

// 날씨 정보 모델
class WeatherInfo {
  final double temperature; // 기온
  final int humidity; // 습도
  final String precipitation; // 강수량
  final double windSpeed; // 풍속
  final SkyCondition skyCondition; // 하늘 상태
  final PrecipitationType precipitationType; // 강수 형태
  final DateTime updateTime;

  WeatherInfo({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.skyCondition,
    required this.precipitationType,
    required this.updateTime,
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

  String get weatherEmoji {
    if (precipitationType != PrecipitationType.none) {
      switch (precipitationType) {
        case PrecipitationType.rain:
        case PrecipitationType.rainDrop:
          return '🌧️';
        case PrecipitationType.snow:
        case PrecipitationType.snowDrop:
          return '❄️';
        case PrecipitationType.rainSnow:
        case PrecipitationType.rainSnowDrop:
          return '🌨️';
        default:
          break;
      }
    }

    switch (skyCondition) {
      case SkyCondition.clear:
        return '☀️';
      case SkyCondition.partlyCloudy:
        return '⛅';
      case SkyCondition.cloudy:
        return '☁️';
    }
  }

  String get advice {
    if (precipitationType == PrecipitationType.rain ||
        precipitationType == PrecipitationType.rainDrop) {
      return '우산을 챙기시고 조기 출발을 권장드려요';
    } else if (precipitationType == PrecipitationType.snow ||
        precipitationType == PrecipitationType.snowDrop) {
      return '눈길 주의! 대중교통 이용을 권장드려요';
    } else if (temperature < 0) {
      return '한파 주의! 따뜻하게 입고 나가세요';
    } else if (temperature > 30) {
      return '더위 주의! 충분한 수분 섭취하세요';
    } else if (skyCondition == SkyCondition.cloudy) {
      return '흐린 날씨네요. 쾌적한 하루 되세요';
    } else {
      return '좋은 날씨네요! 즐거운 하루 되세요';
    }
  }
}

// 날씨 예보 모델
class WeatherForecast {
  final DateTime dateTime;
  final double temperature;
  final double? maxTemperature;
  final double? minTemperature;
  final int humidity;
  final String precipitation;
  final SkyCondition skyCondition;
  final PrecipitationType precipitationType;

  WeatherForecast({
    required this.dateTime,
    required this.temperature,
    this.maxTemperature,
    this.minTemperature,
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