import 'package:http/http.dart' as http;
import 'dart:math' as math;
import '../base/api_client.dart';
import '../constants/api_constants.dart';

/// 기상청 날씨 API 클라이언트
class WeatherApiClient extends BaseApiClient {
  WeatherApiClient({required http.Client httpClient})
      : super(httpClient: httpClient);

  /// 단기 예보 조회
  ///
  /// [nx] : 격자 X좌표
  /// [ny] : 격자 Y좌표
  /// [baseDate] : 조회 날짜 (YYYYMMDD 형식)
  /// [baseTime] : 조회 시간 (HH00 형식)
  Future<Map<String, dynamic>> getWeatherForecast({
    required int nx,
    required int ny,
    required String baseDate,
    required String baseTime,
  }) async {
    final url = ApiConstants.weatherBaseUrl + ApiConstants.getVilageFcst;

    logRequest('GET', url);

    final queryParameters = {
      'serviceKey': ApiConstants.weatherApiKey,
      'pageNo': ApiConstants.weatherPageNo.toString(),
      'numOfRows': ApiConstants.weatherFcstNumOfRows.toString(),
      'dataType': ApiConstants.weatherDataType,
      'base_date': baseDate,
      'base_time': baseTime,
      'nx': nx.toString(),
      'ny': ny.toString(),
    };

    try {
      final response = await get(
        url: url,
        queryParameters: queryParameters,
      );

      print('✅ 날씨 예보 조회 완료');
      return response;
    } catch (e) {
      print('❌ 날씨 예보 조회 실패: $e');
      rethrow;
    }
  }

  /// 초단기 실황 조회 (현재 날씨)
  ///
  /// [nx] : 격자 X좌표
  /// [ny] : 격자 Y좌표
  /// [baseDate] : 조회 날짜 (YYYYMMDD 형식)
  /// [baseTime] : 조회 시간 (HH30 형식)
  Future<Map<String, dynamic>> getCurrentWeather({
    required int nx,
    required int ny,
    required String baseDate,
    required String baseTime,
  }) async {
    final url = ApiConstants.weatherBaseUrl + ApiConstants.getUltraSrtNcst;

    logRequest('GET', url);

    final queryParameters = {
      'serviceKey': ApiConstants.weatherApiKey,
      'pageNo': ApiConstants.weatherPageNo.toString(),
      'numOfRows': ApiConstants.weatherCurrentNumOfRows.toString(),
      'dataType': ApiConstants.weatherDataType,
      'base_date': baseDate,
      'base_time': baseTime,
      'nx': nx.toString(),
      'ny': ny.toString(),
    };

    try {
      final response = await get(
        url: url,
        queryParameters: queryParameters,
      );

      print('✅ 현재 날씨 조회 완료');
      return response;
    } catch (e) {
      print('❌ 현재 날씨 조회 실패: $e');
      rethrow;
    }
  }

  /// 격자 좌표 변환 (위도/경도 → 격자 좌표)
  /// 기상청 API는 위도/경도를 격자 좌표로 변환해야 함
  ///
  /// [latitude] : 위도
  /// [longitude] : 경도
  static Map<String, int> convertCoordinatesToGrid({
    required double latitude,
    required double longitude,
  }) {
    // 기상청 격자 변환 알고리즘
    double re = 6371.00877;           // 지구 반경(km)
    double slat1 = 30.0;              // 표준 위도 1
    double slat2 = 60.0;              // 표준 위도 2
    double olon = 126.0;              // 기준점 경도
    double olat = 38.0;               // 기준점 위도
    double xo = 43;                   // 기준점 X
    double yo = 136;                  // 기준점 Y

    const double degrad = 3.141592653589793 / 180.0;

    slat1 *= degrad;
    slat2 *= degrad;
    olon *= degrad;
    olat *= degrad;

    double sn = (slat2 - slat1) / (2.0 * (slat2 > slat1 ? 1 : -1));
    double sf = (slat1 == 0 ? sn : sn) / sn;
    double ro = ((re * sf * (1 - sn) / sn).abs());

    latitude *= degrad;
    longitude *= degrad;

    double ra = re * sf * ((latitude - olat).abs());
    double theta = sn * ((longitude - olon).abs());

    int x = (xo + (ra * math.sin(theta)).round()).toInt();
    int y = (yo - (ra - ro + (ro * math.cos(theta)).abs()).round()).toInt();

    return {'nx': x, 'ny': y};
  }
}