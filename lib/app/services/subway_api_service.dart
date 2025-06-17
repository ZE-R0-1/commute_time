import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../data/models/subway_arrival_model.dart';
import '../data/models/subway_station_model.dart';

class SubwayApiService extends GetxService {
  late final Dio _dio;

  // API 설정
  static const String _baseUrl = 'http://swopenapi.seoul.go.kr/api/subway';
  static const String _apiKey = '4c6271556f736b313837537a687053';

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  /// Dio 초기화
  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // 인터셉터 추가 (로깅)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('🚇 Subway API: $object'),
      ),
    );
  }

  /// 실시간 지하철 도착정보 조회
  /// [stationName] : 지하철 역명 (예: "강남")
  /// [subwayId] : 지하철 호선 ID (1~9호선, 경의중앙선 등)
  Future<List<SubwayArrival>> getRealtimeArrival({
    required String stationName,
    int? subwayId,
  }) async {
    try {
      print('🚇 실시간 도착정보 요청: $stationName ${subwayId != null ? '${subwayId}호선' : ''}');

      final response = await _dio.get(
        '/$_apiKey/json/realtimeStationArrival/1/10/$stationName',
      );

      print('🚇 API 응답 상태: ${response.statusCode}');
      print('🚇 API 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // API 응답 에러 체크 (서울교통공사 API는 성공해도 errorMessage가 있음)
        if (data['errorMessage'] != null) {
          final errorMsg = data['errorMessage'];
          final status = errorMsg['status'];
          final code = errorMsg['code'];

          // 성공이 아닌 경우에만 에러로 처리
          if (status != 200 || code != 'INFO-000') {
            print('❌ API 에러: ${errorMsg['message']}');
            throw Exception('API 에러: ${errorMsg['message']}');
          }

          print('✅ API 성공: ${errorMsg['message']} (총 ${errorMsg['total']}개)');
        }

        // 데이터 파싱
        final List<dynamic> arrivals = data['realtimeArrivalList'] ?? [];

        List<SubwayArrival> result = arrivals
            .map((json) => SubwayArrival.fromJson(json))
            .toList();

        // 특정 호선 필터링
        if (subwayId != null) {
          result = result.where((arrival) =>
          arrival.subwayId == subwayId.toString()
          ).toList();
        }

        print('✅ 파싱된 도착정보: ${result.length}개');
        return result;
      } else {
        throw Exception('HTTP 에러: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 실시간 도착정보 조회 실패: $e');
      rethrow;
    }
  }

  /// 지하철 역 검색
  /// [keyword] : 검색 키워드 (역명 일부)
  Future<List<SubwayStation>> searchStations(String keyword) async {
    try {
      print('🔍 역 검색: $keyword');

      // 서울교통공사 역 정보 API 호출
      final response = await _dio.get(
        '/$_apiKey/json/SearchInfoBySubwayNameService/1/100/$keyword',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['errorMessage'] != null) {
          print('❌ 검색 API 에러: ${data['errorMessage']['message']}');
          return [];
        }

        final List<dynamic> stations = data['SearchInfoBySubwayNameService']['row'] ?? [];

        List<SubwayStation> result = stations
            .map((json) => SubwayStation.fromJson(json))
            .toList();

        print('✅ 검색된 역: ${result.length}개');
        return result;
      } else {
        throw Exception('HTTP 에러: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 역 검색 실패: $e');
      return [];
    }
  }

  /// 지하철 노선 정보 조회
  Future<Map<String, String>> getSubwayLines() async {
    // 서울 지하철 노선 정보 (하드코딩 - 정적 데이터)
    return {
      '1': '1호선',
      '2': '2호선',
      '3': '3호선',
      '4': '4호선',
      '5': '5호선',
      '6': '6호선',
      '7': '7호선',
      '8': '8호선',
      '9': '9호선',
      'K': '경의중앙선',
      'B': '분당선',
      'A': '공항철도',
      'G': '경춘선',
      'S': '신분당선',
      'I': '인천1호선',
      'I2': '인천2호선',
      'SU': '수인분당선',
      'U': '의정부경전철',
      'UI': '우이신설경전철',
      'W': '서해선',
    };
  }

  /// 노선별 색상 정보
  Map<String, String> getLineColors() {
    return {
      '1': '#263C96',   // 1호선 - 진한 파랑
      '2': '#00A84D',   // 2호선 - 초록
      '3': '#EF7C1C',   // 3호선 - 주황
      '4': '#00A4E3',   // 4호선 - 파랑
      '5': '#996CAC',   // 5호선 - 보라
      '6': '#CD7C2F',   // 6호선 - 갈색
      '7': '#747F00',   // 7호선 - 올리브
      '8': '#E6186C',   // 8호선 - 분홍
      '9': '#BB8336',   // 9호선 - 황토
      'K': '#77C4A3',   // 경의중앙선 - 연한 초록
      'B': '#FFCD12',   // 분당선 - 노랑
      'A': '#0090D2',   // 공항철도 - 하늘색
      'G': '#2FB8AD',   // 경춘선 - 민트
      'S': '#D31145',   // 신분당선 - 빨강
    };
  }

  /// 테스트용 더미 데이터 생성
  List<SubwayArrival> generateDummyArrivals() {
    return [
      SubwayArrival(
        stationName: '강남',
        subwayNm: '2호선',
        subwayId: '1002',
        updnLine: '외선',
        trainLineNm: '성수행 - 역삼방면',
        arvlMsg2: '2분 30초 후 [4]번째 전역 (선릉)',
        arvlMsg3: '5분 12초 후 [7]번째 전역 (선릉)',
        arvlCd: '1',
      ),
      SubwayArrival(
        stationName: '강남',
        subwayNm: '신분당선',
        subwayId: '1077',
        updnLine: '상행',
        trainLineNm: '신사행 - 신논현방면',
        arvlMsg2: '1분 45초 후 [2]번째 전역 (양재시민의숲)',
        arvlMsg3: '4분 23초 후 [5]번째 전역 (양재시민의숲)',
        arvlCd: '1',
      ),
    ];
  }
}