import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GyeonggiBusService {
  static const String baseUrl = 'http://apis.data.go.kr/1613000/BusSttnInfoInqireService';
  
  // 좌표 기반 주변 정류소 조회
  static Future<List<GyeonggiBusStop>> getBusStopsByLocation(
    double lat, 
    double lon, 
    {int radius = 500}
  ) async {
    try {
      final apiKey = dotenv.env['GYEONGGI_BUS_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        print('❌ 경기도 버스 API 키가 없습니다.');
        return [];
      }

      final encodedApiKey = Uri.encodeComponent(apiKey);
      final url = Uri.parse(
        '$baseUrl/getCrdntPrxmtSttnList'
        '?serviceKey=$encodedApiKey'
        '&gpsLati=$lat'
        '&gpsLong=$lon'
        '&numOfRows=10'
        '&pageNo=1'
        '&_type=json'
      );

      print('🚌 경기도 버스정류장 API 요청: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      print('📡 HTTP 응답 상태: ${response.statusCode}');
      print('📄 응답 내용 (첫 500자): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        return _parseJsonResponse(response.body);
      } else {
        print('❌ API 호출 실패: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ 경기도 버스정류장 검색 중 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

  // 정류소명으로 검색
  static Future<List<GyeonggiBusStop>> searchBusStopsByName(String stationName) async {
    try {
      final apiKey = dotenv.env['GYEONGGI_BUS_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        print('❌ 경기도 버스 API 키가 없습니다.');
        return [];
      }

      final encodedApiKey = Uri.encodeComponent(apiKey);
      final url = Uri.parse(
        '$baseUrl/getBusStationList'
        '?serviceKey=$encodedApiKey'
        '&stationName=${Uri.encodeComponent(stationName)}'
      );

      print('🔍 경기도 버스정류장 이름 검색 API 요청: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      print('📡 HTTP 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseJsonResponse(response.body);
      } else {
        print('❌ API 호출 실패: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ 경기도 버스정류장 이름 검색 중 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

  // JSON 응답 파싱
  static List<GyeonggiBusStop> _parseJsonResponse(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      final response = data['response'];
      final body = response['body'];
      final items = body['items'];
      
      List<GyeonggiBusStop> busStops = [];
      
      // items.item 배열 처리
      if (items != null && items['item'] is List) {
        final itemList = items['item'] as List;
        for (final item in itemList) {
          try {
            final busStop = GyeonggiBusStop(
              stationId: item['nodeid']?.toString() ?? '',
              stationName: item['nodenm']?.toString() ?? '',
              x: double.tryParse(item['gpslong']?.toString() ?? '0') ?? 0.0,
              y: double.tryParse(item['gpslati']?.toString() ?? '0') ?? 0.0,
              regionName: item['citycode']?.toString() ?? '',
              districtCd: item['citycode']?.toString() ?? '',
              centerYn: 'N',
              mgmtId: item['nodeid']?.toString() ?? '',
              mobileNo: '',
            );
            
            // 유효한 좌표가 있는 경우만 추가
            if (busStop.x != 0.0 && busStop.y != 0.0) {
              busStops.add(busStop);
            }
          } catch (e) {
            print('❌ 버스정류장 파싱 오류: $e');
            continue;
          }
        }
      }
      
      print('✅ 경기도 버스정류장 파싱 완료! 총 ${busStops.length}개');
      return busStops;
      
    } catch (e, stackTrace) {
      print('❌ JSON 파싱 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

}

// 경기도 버스정류장 모델 클래스
class GyeonggiBusStop {
  final String stationId;      // 정류소ID
  final String stationName;    // 정류소명
  final double x;              // 경도
  final double y;              // 위도
  final String regionName;     // 지역명
  final String districtCd;     // 관할 지역 코드
  final String centerYn;       // 센터 여부
  final String mgmtId;         // 관리ID
  final String mobileNo;       // 모바일번호

  GyeonggiBusStop({
    required this.stationId,
    required this.stationName,
    required this.x,
    required this.y,
    required this.regionName,
    required this.districtCd,
    required this.centerYn,
    required this.mgmtId,
    required this.mobileNo,
  });

  @override
  String toString() {
    return 'GyeonggiBusStop('
        'stationId: $stationId, '
        'stationName: $stationName, '
        'x: $x, y: $y, '
        'regionName: $regionName'
        ')';
  }
}