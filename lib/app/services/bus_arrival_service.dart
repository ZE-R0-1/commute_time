import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BusArrivalService {
  static String get baseUrl => dotenv.env['GYEONGGI_BUS_ARRIVAL_API_URL'] ?? 'https://apis.data.go.kr/6410000/busarrivalservice/v2';
  
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
      final busArrivalData = msgBody['busArrivalList'];
      
      List<BusArrivalInfo> arrivalInfos = [];
      
      // busArrivalList는 단일 객체 또는 배열일 수 있음
      if (busArrivalData != null) {
        List<dynamic> busArrivalList = [];
        
        if (busArrivalData is List) {
          // 배열인 경우
          busArrivalList = busArrivalData;
        } else if (busArrivalData is Map<String, dynamic>) {
          // 단일 객체인 경우 (로그에서 보이는 경우)
          busArrivalList = [busArrivalData];
        }
        
        print('📄 버스도착정보 원본 데이터: $busArrivalData');
        print('✅ 경기도 버스 도착정보 파싱 시작! 총 ${busArrivalList.length}개 항목');
        
        for (int i = 0; i < busArrivalList.length; i++) {
          final item = busArrivalList[i];
          try {
            // routeTypeName 필드가 없을 수 있으므로 routeTypeCd를 기반으로 매핑
            String routeTypeName = '일반';
            final routeTypeCd = item['routeTypeCd']?.toString() ?? '';
            switch (routeTypeCd) {
              case '11':
                routeTypeName = '직행좌석';
                break;
              case '12':
                routeTypeName = '좌석';
                break;
              case '13':
                routeTypeName = '일반';
                break;
              case '21':
                routeTypeName = '광역급행';
                break;
              default:
                routeTypeName = '일반';
            }
            
            final arrivalInfo = BusArrivalInfo(
              routeId: item['routeId']?.toString() ?? '',
              routeName: item['routeName']?.toString() ?? '',
              routeTypeName: routeTypeName,
              stationId: item['stationId']?.toString() ?? '',
              stationName: item['stationName']?.toString() ?? '',
              predictTime1: int.tryParse(item['predictTime1']?.toString() ?? '0') ?? 0,
              predictTime2: int.tryParse(item['predictTime2']?.toString() ?? '0') ?? 0,
              locationNo1: int.tryParse(item['locationNo1']?.toString() ?? '0') ?? 0,
              locationNo2: int.tryParse(item['locationNo2']?.toString() ?? '0') ?? 0,
              lowPlate1: item['lowPlate1']?.toString() == '1' ? 'Y' : 'N',
              lowPlate2: item['lowPlate2']?.toString() == '1' ? 'Y' : 'N',
              plateNo1: item['plateNo1']?.toString() ?? '',
              plateNo2: item['plateNo2']?.toString() ?? '',
              remainSeatCnt1: int.tryParse(item['remainSeatCnt1']?.toString() ?? '0') ?? 0,
              remainSeatCnt2: int.tryParse(item['remainSeatCnt2']?.toString() ?? '0') ?? 0,
              staOrder: int.tryParse(item['staOrder']?.toString() ?? '0') ?? 0,
            );
            
            arrivalInfos.add(arrivalInfo);
            
            print('경기도 버스 도착정보 ${i + 1}. ${arrivalInfo.routeName}번 (${arrivalInfo.routeTypeName})');
            print('   - 첫번째 버스: ${arrivalInfo.predictTime1}분 후, ${arrivalInfo.locationNo1}정류장 전');
            print('   - 두번째 버스: ${arrivalInfo.predictTime2}분 후, ${arrivalInfo.locationNo2}정류장 전');
            print('   - 저상버스: 1번(${arrivalInfo.lowPlate1}), 2번(${arrivalInfo.lowPlate2})');
            print('');
          } catch (e) {
            print('❌ 버스 도착정보 파싱 오류 ($i번째): $e');
            print('   - 원본 데이터: $item');
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
  final int staOrder;            // 정류소 순번
  final DateTime loadedAt;       // 데이터 로드 시간

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
    required this.staOrder,
    DateTime? loadedAt,
  }) : loadedAt = loadedAt ?? DateTime.now();

  // 실시간 카운트다운을 위한 계산된 시간 (초 단위)
  int get predictTimeInSeconds1 {
    final elapsed = DateTime.now().difference(loadedAt).inSeconds;
    final totalSeconds = predictTime1 * 60;
    final remaining = totalSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  int get predictTimeInSeconds2 {
    final elapsed = DateTime.now().difference(loadedAt).inSeconds;
    final totalSeconds = predictTime2 * 60;
    final remaining = totalSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  // 포맷된 시간 표시 (분:초)
  String get formattedTime1 {
    final seconds = predictTimeInSeconds1;
    if (seconds <= 0) return '곧 도착';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}분 ${remainingSeconds}초';
  }

  String get formattedTime2 {
    final seconds = predictTimeInSeconds2;
    if (seconds <= 0) return '곧 도착';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}분 ${remainingSeconds}초';
  }

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