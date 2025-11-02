import 'package:http/http.dart' as http;
import '../base/api_client.dart';
import '../constants/api_constants.dart';

/// 서울 지하철 API 클라이언트
class SubwayApiClient extends BaseApiClient {
  SubwayApiClient({required http.Client httpClient})
      : super(httpClient: httpClient);

  /// 지하철 역 도착정보 조회
  ///
  /// [stationName] : 역 이름 (정확한 이름 필요)
  /// [startIndex] : 시작 인덱스 (기본값: 0)
  /// [endIndex] : 종료 인덱스 (기본값: 10)
  Future<Map<String, dynamic>> getStationArrival({
    required String stationName,
    int startIndex = ApiConstants.seoulSubwayStartIndex,
    int endIndex = ApiConstants.seoulSubwayEndIndex,
  }) async {
    // URL 구성: /api/subway/{API_KEY}/json/realtimeStationArrival/{startIndex}/{endIndex}/{stationName}
    final apiKey = ApiConstants.seoulSubwayApiKey;
    final url =
        '${ApiConstants.seoulSubwayBaseUrl}/$apiKey${ApiConstants.getRealtimeStationArrival}/$startIndex/$endIndex/$stationName';

    logRequest('GET', url);

    try {
      final response = await get(url: url);

      print('✅ 지하철 도착정보 조회 완료: $stationName');
      return response;
    } catch (e) {
      print('❌ 지하철 도착정보 조회 실패: $e');
      rethrow;
    }
  }

  /// 역 이름으로 도착정보 조회 (래퍼 메서드)
  ///
  /// [stationName] : 역 이름
  Future<Map<String, dynamic>> getArrivalByStationName({
    required String stationName,
  }) {
    return getStationArrival(stationName: stationName);
  }

  /// 자주 사용하는 역들 - 편의 메서드

  /// 강남역 도착정보
  Future<Map<String, dynamic>> getGangnamStationArrival() {
    return getArrivalByStationName(stationName: '강남');
  }

  /// 역삼역 도착정보
  Future<Map<String, dynamic>> getYoksamStationArrival() {
    return getArrivalByStationName(stationName: '역삼');
  }

  /// 서울역 도착정보
  Future<Map<String, dynamic>> getSeoulStationArrival() {
    return getArrivalByStationName(stationName: '서울');
  }

  /// 용산역 도착정보
  Future<Map<String, dynamic>> getYongsanStationArrival() {
    return getArrivalByStationName(stationName: '용산');
  }

  /// 동대문역 도착정보
  Future<Map<String, dynamic>> getDongdaemunStationArrival() {
    return getArrivalByStationName(stationName: '동대문');
  }

  /// 한양대역 도착정보
  Future<Map<String, dynamic>> getHanyangDaeStationArrival() {
    return getArrivalByStationName(stationName: '한양대');
  }

  /// 광진구청역 도착정보
  Future<Map<String, dynamic>> getGwangjinguStationArrival() {
    return getArrivalByStationName(stationName: '광진구청');
  }

  /// 사당역 도착정보
  Future<Map<String, dynamic>> getSadangStationArrival() {
    return getArrivalByStationName(stationName: '사당');
  }

  /// 동작대학역 도착정보
  Future<Map<String, dynamic>> getDongjagUnivStationArrival() {
    return getArrivalByStationName(stationName: '동작대학');
  }

  /// 이화여대역 도착정보
  Future<Map<String, dynamic>> getEwhaDaeStationArrival() {
    return getArrivalByStationName(stationName: '이화여대');
  }
}