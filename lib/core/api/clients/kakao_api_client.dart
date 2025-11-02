import 'package:http/http.dart' as http;
import '../base/api_client.dart';
import '../constants/api_constants.dart';

/// 카카오 로컬 API 클라이언트
/// 주소 검색, 장소 검색, 좌표 변환 등을 처리합니다.
class KakaoApiClient extends BaseApiClient {
  KakaoApiClient({required http.Client httpClient})
      : super(httpClient: httpClient);

  /// 키워드로 장소 검색
  ///
  /// [query] : 검색어
  /// [size] : 결과 개수 (기본값: 10)
  /// [page] : 페이지 번호 (기본값: 1)
  Future<Map<String, dynamic>> searchKeyword({
    required String query,
    int size = ApiConstants.kakaoSearchSize,
    int page = 1,
  }) async {
    final url = ApiConstants.kakaoBaseUrl + ApiConstants.searchKeyword;

    logRequest('GET', url);

    final queryParameters = {
      'query': query,
      'size': size.toString(),
      'page': page.toString(),
    };

    final headers = {
      'Authorization': 'KakaoAK ${ApiConstants.kakaoApiKey}',
    };

    try {
      final response = await get(
        url: url,
        headers: headers,
        queryParameters: queryParameters,
      );

      print('✅ 키워드 검색 완료: $query');
      return response;
    } catch (e) {
      print('❌ 키워드 검색 실패: $e');
      rethrow;
    }
  }

  /// 주소로 장소 검색
  ///
  /// [query] : 검색할 주소
  /// [size] : 결과 개수 (기본값: 10)
  /// [page] : 페이지 번호 (기본값: 1)
  Future<Map<String, dynamic>> searchAddress({
    required String query,
    int size = ApiConstants.kakaoSearchSize,
    int page = 1,
  }) async {
    final url = ApiConstants.kakaoBaseUrl + ApiConstants.searchAddress;

    logRequest('GET', url);

    final queryParameters = {
      'query': query,
      'size': size.toString(),
      'page': page.toString(),
    };

    final headers = {
      'Authorization': 'KakaoAK ${ApiConstants.kakaoApiKey}',
    };

    try {
      final response = await get(
        url: url,
        headers: headers,
        queryParameters: queryParameters,
      );

      print('✅ 주소 검색 완료: $query');
      return response;
    } catch (e) {
      print('❌ 주소 검색 실패: $e');
      rethrow;
    }
  }

  /// 카테고리로 장소 검색
  ///
  /// [categoryCode] : 카테고리 코드 (SW8: 지하철역, CE7: 카페 등)
  /// [x] : 경도
  /// [y] : 위도
  /// [radius] : 반경 (미터, 기본값: 1000)
  /// [sort] : 정렬 방식 (distance: 거리순)
  /// [size] : 결과 개수 (기본값: 15)
  Future<Map<String, dynamic>> searchCategory({
    required String categoryCode,
    required double x,
    required double y,
    int radius = ApiConstants.kakaoSearchRadius,
    String sort = ApiConstants.kakaoSearchSort,
    int size = ApiConstants.kakaoCategorySize,
  }) async {
    final url = ApiConstants.kakaoBaseUrl + ApiConstants.searchCategory;

    logRequest('GET', url);

    final queryParameters = {
      'category_group_code': categoryCode,
      'x': x.toString(),
      'y': y.toString(),
      'radius': radius.toString(),
      'sort': sort,
      'size': size.toString(),
    };

    final headers = {
      'Authorization': 'KakaoAK ${ApiConstants.kakaoApiKey}',
    };

    try {
      final response = await get(
        url: url,
        headers: headers,
        queryParameters: queryParameters,
      );

      print('✅ 카테고리 검색 완료: $categoryCode');
      print('📊 API 응답 데이터: $response');
      return response;
    } catch (e) {
      print('❌ 카테고리 검색 실패: $e');
      rethrow;
    }
  }

  /// 좌표를 주소로 변환 (역지오코딩)
  ///
  /// [x] : 경도
  /// [y] : 위도
  Future<Map<String, dynamic>> convertCoordinateToAddress({
    required double x,
    required double y,
  }) async {
    final url = ApiConstants.kakaoBaseUrl + ApiConstants.coord2Address;

    logRequest('GET', url);

    final queryParameters = {
      'x': x.toString(),
      'y': y.toString(),
    };

    final headers = {
      'Authorization': 'KakaoAK ${ApiConstants.kakaoApiKey}',
    };

    try {
      final response = await get(
        url: url,
        headers: headers,
        queryParameters: queryParameters,
      );

      print('✅ 좌표 변환 완료: ($x, $y)');
      return response;
    } catch (e) {
      print('❌ 좌표 변환 실패: $e');
      rethrow;
    }
  }

  /// 지하철역 검색 (카테고리 검색 래퍼)
  Future<Map<String, dynamic>> searchSubwayStations({
    required double x,
    required double y,
    int radius = ApiConstants.kakaoSearchRadius,
    int size = ApiConstants.kakaoCategorySize,
  }) {
    return searchCategory(
      categoryCode: 'SW8',  // 지하철역
      x: x,
      y: y,
      radius: radius,
      size: size,
    );
  }

  /// 카페 검색 (카테고리 검색 래퍼)
  Future<Map<String, dynamic>> searchCafes({
    required double x,
    required double y,
    int radius = ApiConstants.kakaoSearchRadius,
    int size = ApiConstants.kakaoCategorySize,
  }) {
    return searchCategory(
      categoryCode: 'CE7',  // 카페
      x: x,
      y: y,
      radius: radius,
      size: size,
    );
  }
}