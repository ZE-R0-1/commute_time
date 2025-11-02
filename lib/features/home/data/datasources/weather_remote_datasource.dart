import 'dart:convert';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../../../../core/api/services/api_provider.dart';
import '../../../../core/exception/exceptions.dart';
import '../models/weather_response.dart';

// Weather DataSource 인터페이스
abstract class WeatherRemoteDataSource {
  Future<List<WeatherForecastResponse>> getWeatherForecast(
    double latitude,
    double longitude,
  );

  Future<WeatherResponse?> getCurrentWeather(
    double latitude,
    double longitude,
  );
}

// Weather DataSource 구현체
class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  WeatherRemoteDataSourceImpl();

  // 기상청 격자 좌표 변환 (위도/경도 → 격자 X,Y)
  Map<String, int> _convertToGrid(double lat, double lon) {
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

  // 기준 시간 계산 (초단기실황) - 40분 단위 업데이트
  String _getBaseTime(DateTime now) {
    final hour = now.hour;
    final minute = now.minute;

    if (minute < 10) {
      final prevHour = hour == 0 ? 23 : hour - 1;
      return prevHour.toString().padLeft(2, '0') + '00';
    } else {
      return hour.toString().padLeft(2, '0') + '00';
    }
  }

  // 예보 기준 시간 계산 (단기예보) - 2,5,8,11,14,17,20,23시 발표
  String _getForecastBaseTime(DateTime now) {
    final hour = now.hour;
    const List<int> baseTimes = [2, 5, 8, 11, 14, 17, 20, 23];

    int baseHour = 23;
    for (int time in baseTimes) {
      if (hour >= time) {
        baseHour = time;
      }
    }

    return baseHour.toString().padLeft(2, '0') + '00';
  }

  // 날짜 포맷 (YYYYMMDD)
  String _formatDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<WeatherForecastResponse>> getWeatherForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      final grid = _convertToGrid(latitude, longitude);
      final now = DateTime.now();
      final baseTime = _getForecastBaseTime(now);
      final baseDate = _formatDate(now);

      print('🌐 날씨 예보 API 호출: $baseDate $baseTime (격자: ${grid['x']}, ${grid['y']})');

      final responseData = await apiProvider.weatherClient.getWeatherForecast(
        nx: grid['x']!,
        ny: grid['y']!,
        baseDate: baseDate,
        baseTime: baseTime,
      );

      final itemList = responseData['response']?['body']?['items']?['item'] as List?;

      if (itemList == null || itemList.isEmpty) {
        print('⚠️ 예보 데이터가 없습니다');
        return [];
      }

      return _parseWeatherForecast(itemList);
    } on Exception catch (e) {
      print('❌ 날씨 예보 조회 실패: $e');
      throw GeneralException(
        message: '날씨 예보 조회 중 오류 발생: ${e.toString()}',
      );
    }
  }

  @override
  Future<WeatherResponse?> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final grid = _convertToGrid(latitude, longitude);
      final now = DateTime.now();
      final baseTime = _getBaseTime(now);
      final baseDate = _formatDate(now);

      print('🌐 현재 날씨 API 호출: $baseDate $baseTime');

      final responseData = await apiProvider.weatherClient.getCurrentWeather(
        nx: grid['x']!,
        ny: grid['y']!,
        baseDate: baseDate,
        baseTime: baseTime,
      );

      final itemList = responseData['response']?['body']?['items']?['item'] as List?;

      if (itemList == null || itemList.isEmpty) {
        return null;
      }

      Map<String, String> weatherData = {};
      for (var item in itemList) {
        weatherData[item['category']] = item['obsrValue'];
      }

      return WeatherResponse(
        temperature: double.tryParse(weatherData['T1H'] ?? '0') ?? 0,
        humidity: int.tryParse(weatherData['REH'] ?? '0') ?? 0,
        precipitation: weatherData['RN1'] ?? '0',
        skyCondition: weatherData['SKY'] ?? '1',
        precipitationType: weatherData['PTY'] ?? '0',
      );
    } catch (e) {
      print('❌ 현재 날씨 조회 실패: $e');
      throw GeneralException(
        message: '현재 날씨 조회 중 오류 발생: ${e.toString()}',
      );
    }
  }

  // 날씨 예보 파싱
  List<WeatherForecastResponse> _parseWeatherForecast(List<dynamic> items) {
    Map<String, Map<String, String>> forecastData = {};

    for (var item in items) {
      final fcstDate = item['fcstDate'];
      final fcstTime = item['fcstTime'];
      final category = item['category'];
      final fcstValue = item['fcstValue'];

      if (fcstDate == null || fcstTime == null || category == null) continue;

      final dateTime = '${fcstDate}_${fcstTime}';
      forecastData[dateTime] ??= {};
      forecastData[dateTime]![category] = fcstValue?.toString() ?? '';
    }

    List<WeatherForecastResponse> forecasts = [];
    forecastData.forEach((dateTime, forecastValues) {
      final parts = dateTime.split('_');
      final date = parts[0];
      final time = parts[1];

      try {
        final forecastDateTime = DateTime(
          int.parse(date.substring(0, 4)),
          int.parse(date.substring(4, 6)),
          int.parse(date.substring(6, 8)),
          int.parse(time.substring(0, 2)),
        );

        forecasts.add(WeatherForecastResponse(
          dateTime: forecastDateTime,
          temperature: double.tryParse(forecastValues['TMP'] ?? '0') ?? 0,
          humidity: int.tryParse(forecastValues['REH'] ?? '0') ?? 0,
          precipitation: forecastValues['PCP'] ?? '0',
          skyCondition: forecastValues['SKY'] ?? '1',
          precipitationType: forecastValues['PTY'] ?? '0',
        ));
      } catch (e) {
        print('⚠️ 예보 데이터 파싱 오류 ($dateTime): $e');
      }
    });

    forecasts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return forecasts;
  }
}