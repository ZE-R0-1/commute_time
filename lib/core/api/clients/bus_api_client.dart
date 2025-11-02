import 'package:http/http.dart' as http;
import '../base/api_client.dart';
import '../constants/api_constants.dart';

/// 버스 API 클라이언트 (서울 + 경기도)
class BusApiClient extends BaseApiClient {
  BusApiClient({required http.Client httpClient})
      : super(httpClient: httpClient);

  // ===== 경기도 버스 API =====

  /// 경기도 정류소 주변 검색
  ///
  /// [x] : 경도
  /// [y] : 위도
  /// [radius] : 반경 (미터, 기본값: 500)
  Future<Map<String, dynamic>> searchGyeonggiBusStops({
    required double x,
    required double y,
    int radius = ApiConstants.gyeonggiBusSearchRadius,
  }) async {
    final url = ApiConstants.gyeonggiBusStationBaseUrl +
        ApiConstants.getBusStationAroundListv2;

    logRequest('GET', url);

    final queryParameters = {
      'serviceKey': ApiConstants.gyeonggiBusApiKey,
      'x': x.toString(),
      'y': y.toString(),
      'format': ApiConstants.gyeonggiBusDataType,
    };

    try {
      final response = await get(
        url: url,
        queryParameters: queryParameters,
      );

      print('✅ 경기도 정류소 검색 완료: ($x, $y)');
      return response;
    } catch (e) {
      print('❌ 경기도 정류소 검색 실패: $e');
      rethrow;
    }
  }

  /// 경기도 버스 도착정보 조회
  ///
  /// [stationId] : 정류소 ID
  Future<Map<String, dynamic>> getGyeonggiBusArrival({
    required String stationId,
  }) async {
    final url = ApiConstants.gyeonggiBusArrivalBaseUrl +
        ApiConstants.getBusArrivalListv2;

    logRequest('GET', url);

    final queryParameters = {
      'serviceKey': ApiConstants.gyeonggiBusApiKey,
      'stationId': stationId,
      'format': ApiConstants.gyeonggiBusDataType,
    };

    try {
      final response = await get(
        url: url,
        queryParameters: queryParameters,
      );

      print('✅ 경기도 버스 도착정보 조회 완료: $stationId');
      return response;
    } catch (e) {
      print('❌ 경기도 버스 도착정보 조회 실패: $e');
      rethrow;
    }
  }

  /// 경기도 버스 상세 도착정보
  ///
  /// [stationId] : 정류소 ID
  /// [routeId] : 노선 ID
  /// [staOrder] : 정류소 순서
  Future<Map<String, dynamic>> getGyeonggiBusArrivalDetail({
    required String stationId,
    required String routeId,
    required int staOrder,
  }) async {
    final url = ApiConstants.gyeonggiBusArrivalBaseUrl +
        ApiConstants.getBusArrivalItemv2;

    logRequest('GET', url);

    final queryParameters = {
      'serviceKey': ApiConstants.gyeonggiBusApiKey,
      'stationId': stationId,
      'routeId': routeId,
      'staOrder': staOrder.toString(),
      'format': ApiConstants.gyeonggiBusDataType,
    };

    try {
      final response = await get(
        url: url,
        queryParameters: queryParameters,
      );

      print('✅ 경기도 버스 상세 도착정보 조회 완료');
      return response;
    } catch (e) {
      print('❌ 경기도 버스 상세 도착정보 조회 실패: $e');
      rethrow;
    }
  }

  // ===== 서울 버스 API =====

  /// 서울 정류소 좌표 기반 검색
  ///
  /// [latitude] : 위도
  /// [longitude] : 경도
  /// [numOfRows] : 결과 개수 (기본값: 10)
  Future<Map<String, dynamic>> searchSeoulBusStops({
    required double latitude,
    required double longitude,
    int numOfRows = ApiConstants.seoulBusSearchNumOfRows,
  }) async {
    final url = ApiConstants.seoulBusStationBaseUrl +
        ApiConstants.getCrdntPrxmtSttnList;

    logRequest('GET', url);

    final queryParameters = {
      'serviceKey': ApiConstants.seoulBusApiKey,
      'gpsLati': latitude.toString(),
      'gpsLong': longitude.toString(),
      'numOfRows': numOfRows.toString(),
      'pageNo': ApiConstants.seoulBusSearchPageNo.toString(),
      '_type': ApiConstants.seoulBusDataType,
    };

    try {
      final response = await get(
        url: url,
        queryParameters: queryParameters,
      );

      print('✅ 서울 정류소 검색 완료: ($latitude, $longitude)');
      return response;
    } catch (e) {
      print('❌ 서울 정류소 검색 실패: $e');
      rethrow;
    }
  }

  /// 서울 버스 도착정보 조회
  ///
  /// [cityCode] : 도시 코드
  /// [nodeId] : 정류소 ID (nodeid)
  Future<Map<String, dynamic>> getSeoulBusArrival({
    required String cityCode,
    required String nodeId,
  }) async {
    final url = ApiConstants.seoulBusArrivalBaseUrl +
        ApiConstants.getArrInfoByStId;

    logRequest('GET', url);

    final queryParameters = {
      'serviceKey': ApiConstants.seoulBusApiKey,
      'cityCode': cityCode,
      'nodeId': nodeId,
      'numOfRows': '10',
      'pageNo': '1',
      '_type': ApiConstants.seoulBusDataType,
    };

    print('🔍 서울 버스 도착정보 API 요청 상세:');
    print('   - URL: $url');
    print('   - cityCode: $cityCode');
    print('   - nodeId: $nodeId');
    print('   - serviceKey: ${ApiConstants.seoulBusApiKey.isNotEmpty ? '존재' : '없음'}');
    print('   - _type: ${ApiConstants.seoulBusDataType}');

    try {
      final response = await get(
        url: url,
        queryParameters: queryParameters,
      );

      print('✅ 서울 버스 도착정보 조회 완료: cityCode=$cityCode, nodeId=$nodeId');
      return response;
    } catch (e) {
      print('❌ 서울 버스 도착정보 조회 실패: $e');
      rethrow;
    }
  }
}