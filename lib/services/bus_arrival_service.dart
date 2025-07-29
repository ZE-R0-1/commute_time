import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BusArrivalService {
  static const String baseUrl = 'https://apis.data.go.kr/6410000/busarrivalservice/v2';
  
  // 정류소별 버스 도착정보 조회
  static Future<List<BusArrivalInfo>> getBusArrivalInfo(String stationId) async {
    try {
      final apiKey = dotenv.env['GYEONGGI_BUS_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        print('❌ 경기도 버스 API 키가 없습니다.');
        return [];
      }

      final encodedApiKey = Uri.encodeComponent(apiKey);
      final url = Uri.parse(
        '$baseUrl/getBusArrivalListv2'
        '?serviceKey=$encodedApiKey'
        '&stationId=$stationId'
        '&format=json'
      );

      print('🚌 버스 도착정보 API 요청: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      print('📡 HTTP 응답 상태: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📄 응답 내용 (첫 500자): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
      }

      if (response.statusCode == 200) {
        return _parseArrivalResponse(response.body);
      } else {
        print('❌ API 호출 실패: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ 버스 도착정보 검색 중 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

  // JSON 응답 파싱
  static List<BusArrivalInfo> _parseArrivalResponse(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      final response = data['response'];
      final msgBody = response['msgBody'];
      final busArrivalList = msgBody['busArrivalList'];
      
      List<BusArrivalInfo> arrivalInfos = [];
      
      // busArrivalList 배열 처리
      if (busArrivalList != null && busArrivalList is List) {
        for (final item in busArrivalList) {
          try {
            final arrivalInfo = BusArrivalInfo(
              routeId: item['routeId']?.toString() ?? '',
              routeName: item['routeName']?.toString() ?? '',
              routeTypeName: item['routeTypeName']?.toString() ?? '',
              stationId: item['stationId']?.toString() ?? '',
              stationName: item['stationName']?.toString() ?? '',
              predictTime1: int.tryParse(item['predictTime1']?.toString() ?? '0') ?? 0,
              predictTime2: int.tryParse(item['predictTime2']?.toString() ?? '0') ?? 0,
              locationNo1: int.tryParse(item['locationNo1']?.toString() ?? '0') ?? 0,
              locationNo2: int.tryParse(item['locationNo2']?.toString() ?? '0') ?? 0,
              lowPlate1: item['lowPlate1']?.toString() ?? 'N',
              lowPlate2: item['lowPlate2']?.toString() ?? 'N',
              plateNo1: item['plateNo1']?.toString() ?? '',
              plateNo2: item['plateNo2']?.toString() ?? '',
              remainSeatCnt1: int.tryParse(item['remainSeatCnt1']?.toString() ?? '0') ?? 0,
              remainSeatCnt2: int.tryParse(item['remainSeatCnt2']?.toString() ?? '0') ?? 0,
            );
            
            arrivalInfos.add(arrivalInfo);
          } catch (e) {
            print('❌ 버스 도착정보 파싱 오류: $e');
            continue;
          }
        }
      }
      
      print('✅ 버스 도착정보 파싱 완료! 총 ${arrivalInfos.length}개');
      return arrivalInfos;
      
    } catch (e, stackTrace) {
      print('❌ JSON 파싱 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }
}

// 버스 도착정보 모델 클래스
class BusArrivalInfo {
  final String routeId;          // 노선ID
  final String routeName;        // 노선명
  final String routeTypeName;    // 노선유형명
  final String stationId;        // 정류소ID
  final String stationName;      // 정류소명
  final int predictTime1;        // 첫번째차량 도착예정시간(분)
  final int predictTime2;        // 두번째차량 도착예정시간(분)
  final int locationNo1;         // 첫번째차량 현재위치 정류장수
  final int locationNo2;         // 두번째차량 현재위치 정류장수
  final String lowPlate1;        // 첫번째차량 저상버스여부(Y/N)
  final String lowPlate2;        // 두번째차량 저상버스여부(Y/N)
  final String plateNo1;         // 첫번째차량 차량번호
  final String plateNo2;         // 두번째차량 차량번호
  final int remainSeatCnt1;      // 첫번째차량 빈자리수
  final int remainSeatCnt2;      // 두번째차량 빈자리수

  BusArrivalInfo({
    required this.routeId,
    required this.routeName,
    required this.routeTypeName,
    required this.stationId,
    required this.stationName,
    required this.predictTime1,
    required this.predictTime2,
    required this.locationNo1,
    required this.locationNo2,
    required this.lowPlate1,
    required this.lowPlate2,
    required this.plateNo1,
    required this.plateNo2,
    required this.remainSeatCnt1,
    required this.remainSeatCnt2,
  });

  @override
  String toString() {
    return 'BusArrivalInfo('
        'routeName: $routeName, '
        'predictTime1: ${predictTime1}분, '
        'predictTime2: ${predictTime2}분, '
        'locationNo1: ${locationNo1}정류장, '
        'locationNo2: ${locationNo2}정류장'
        ')';
  }
}