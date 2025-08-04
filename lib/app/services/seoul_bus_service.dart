import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 서울 버스 도착정보 모델 (API 문서 기준)
class SeoulBusArrival {
  final String nodeId;         // 정류소ID
  final String nodeNm;         // 정류소명
  final String routeId;        // 노선ID
  final String routeNo;        // 노선번호
  final String routeTp;        // 노선유형
  final int arrPrevStationCnt; // 도착예정버스 남은 정류장 수
  final String vehicleTp;      // 도착예정버스 차량유형
  final int arrTime;           // 도착예정버스 도착예상시간(초)

  SeoulBusArrival({
    required this.nodeId,
    required this.nodeNm,
    required this.routeId,
    required this.routeNo,
    required this.routeTp,
    required this.arrPrevStationCnt,
    required this.vehicleTp,
    required this.arrTime,
  });

  factory SeoulBusArrival.fromJson(Map<String, dynamic> json) {
    return SeoulBusArrival(
      nodeId: json['nodeid']?.toString() ?? '',
      nodeNm: json['nodenm']?.toString() ?? '',
      routeId: json['routeid']?.toString() ?? '',
      routeNo: json['routeno']?.toString() ?? '',
      routeTp: json['routetp']?.toString() ?? '',
      arrPrevStationCnt: int.tryParse(json['arrprevstationcnt']?.toString() ?? '0') ?? 0,
      vehicleTp: json['vehicletp']?.toString() ?? '',
      arrTime: int.tryParse(json['arrtime']?.toString() ?? '0') ?? 0,
    );
  }

  // 도착시간을 분으로 변환
  int get arrTimeInMinutes => (arrTime / 60).round();

  @override
  String toString() {
    return 'SeoulBusArrival{nodeId: $nodeId, nodeNm: $nodeNm, routeNo: $routeNo, routeTp: $routeTp, arrTime: ${arrTimeInMinutes}분}';
  }
}

// 서울 버스정류장 정보 모델
class SeoulBusStop {
  final String stationId;      // 정류소ID
  final String stationNm;      // 정류소명
  final double gpsX;           // GPS X좌표 (경도)
  final double gpsY;           // GPS Y좌표 (위도)
  final String direction;      // 방면정보
  final String stationTp;      // 정류소타입 (0:일반, 1:공항)
  final String regionName;     // 지역명 (서울)

  SeoulBusStop({
    required this.stationId,
    required this.stationNm,
    required this.gpsX,
    required this.gpsY,
    required this.direction,
    required this.stationTp,
    this.regionName = '서울',
  });

  factory SeoulBusStop.fromJson(Map<String, dynamic> json) {
    return SeoulBusStop(
      stationId: json['nodeid']?.toString() ?? '', // nodeid -> stationId
      stationNm: json['nodenm']?.toString() ?? '', // nodenm -> stationNm
      gpsX: double.tryParse(json['gpslong']?.toString() ?? '0') ?? 0.0, // gpslong -> gpsX (경도)
      gpsY: double.tryParse(json['gpslati']?.toString() ?? '0') ?? 0.0, // gpslati -> gpsY (위도)
      direction: json['direction']?.toString() ?? '', // direction 필드는 서울 API에 없음
      stationTp: json['stationTp']?.toString() ?? '0', // stationTp 필드는 서울 API에 없음
    );
  }

  @override
  String toString() {
    return 'SeoulBusStop{stationId: $stationId, stationNm: $stationNm, gpsX: $gpsX, gpsY: $gpsY, direction: $direction, stationTp: $stationTp}';
  }
}

class SeoulBusService {
  /// 좌표 기반으로 서울 버스정류장 검색
  static Future<List<SeoulBusStop>> getBusStopsByLocation(
    double latitude,
    double longitude, {
    int radius = 500,
    int numOfRows = 10,
    int pageNo = 1,
  }) async {
    try {
      print('🏢 서울 버스정류장 API 검색 시작');
      print('📍 검색 좌표: ($latitude, $longitude)');
      print('📏 반경: ${radius}m, 최대 개수: $numOfRows');

      // 환경변수에서 서울 버스 API 키와 URL 가져오기
      final serviceKey = dotenv.env['SEOUL_BUS_API_KEY'] ?? '';
      final baseUrl = dotenv.env['SEOUL_BUS_API_URL'] ?? '';
      
      if (serviceKey.isEmpty || baseUrl.isEmpty) {
        print('❌ 서울 버스 API 키 또는 URL이 없습니다.');
        return [];
      }

      print('🔑 서울 버스 API 키 확인: ${serviceKey.substring(0, 10)}...');

      // 경기버스 방식과 동일하게 URL 구성
      final encodedServiceKey = Uri.encodeComponent(serviceKey);
      final uri = Uri.parse(
        '$baseUrl'
        '?serviceKey=$encodedServiceKey'
        '&gpsLati=$latitude'
        '&gpsLong=$longitude'
        '&numOfRows=$numOfRows'
        '&pageNo=$pageNo'
        '&_type=json'
      );

      print('🔍 서울 API 요청 URL: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      print('📡 서울 API 응답 상태: ${response.statusCode}');
      print('📄 응답 내용 (첫 500자): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 응답 구조 확인
        if (data['response'] != null && 
            data['response']['body'] != null && 
            data['response']['body']['items'] != null) {
          
          final items = data['response']['body']['items'];
          
          // items가 List인지 Map인지 확인
          List<dynamic> itemList = [];
          if (items is List) {
            itemList = items;
          } else if (items is Map && items['item'] != null) {
            if (items['item'] is List) {
              itemList = items['item'];
            } else {
              itemList = [items['item']];
            }
          }

          print('✅ 서울 API 파싱 완료! 총 ${itemList.length}개의 버스정류장 발견');

          List<SeoulBusStop> busStops = [];
          for (int i = 0; i < itemList.length; i++) {
            final item = itemList[i];
            if (item is Map<String, dynamic>) {
              try {
                final busStop = SeoulBusStop.fromJson(item);
                busStops.add(busStop);
                
                print('서울 ${i + 1}. ${busStop.stationNm}');
                print('   - 노드ID: ${busStop.stationId}');
                print('   - 좌표: (${busStop.gpsY}, ${busStop.gpsX})');
                print('   - 도시코드: ${item['citycode']}');
                print('');
              } catch (e) {
                print('❌ 서울 버스정류장 파싱 오류 ($i번째): $e');
                print('   - 원본 데이터: $item');
              }
            }
          }

          return busStops;
        } else {
          print('❌ 서울 API 응답 구조 오류');
          print('📄 전체 응답: ${response.body}');
          return [];
        }
      } else {
        print('❌ 서울 API 호출 실패: ${response.statusCode}');
        print('📄 응답 내용: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ 서울 버스정류장 검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

  /// 정류장별 버스 도착정보 조회
  static Future<List<SeoulBusArrival>> getBusArrivalInfo(
    String cityCode,
    String nodeId, {
    int numOfRows = 10,
    int pageNo = 1,
  }) async {
    try {
      print('🚌 서울 버스 도착정보 API 검색 시작');
      print('📍 도시코드: $cityCode, 노드ID: $nodeId');

      // 환경변수에서 서울 버스 도착정보 API 키와 URL 가져오기
      final serviceKey = dotenv.env['SEOUL_BUS_API_KEY'] ?? '';
      final baseUrl = dotenv.env['SEOUL_BUS_ARRIVAL_API_URL'] ?? '';
      
      if (serviceKey.isEmpty || baseUrl.isEmpty) {
        print('❌ 서울 버스 도착정보 API 키 또는 URL이 없습니다.');
        return [];
      }

      print('🔑 서울 버스 API 키 확인: ${serviceKey.substring(0, 10)}...');

      // API 요청 URL 구성
      final encodedServiceKey = Uri.encodeComponent(serviceKey);
      final uri = Uri.parse(
        '$baseUrl'
        '?serviceKey=$encodedServiceKey'
        '&cityCode=$cityCode'
        '&nodeId=$nodeId'
        '&numOfRows=$numOfRows'
        '&pageNo=$pageNo'
        '&_type=json'
      );

      print('🔍 서울 도착정보 API 요청 URL: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      print('📡 서울 도착정보 API 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 서울 버스 도착정보 API 응답 구조 확인 (실제 응답: response.body.items.item)
        if (data['response'] != null && 
            data['response']['body'] != null) {

          List<SeoulBusArrival> arrivals = [];
          
          // items.item 구조 확인
          final body = data['response']['body'];
          if (body['items'] != null && body['items']['item'] != null) {
            final items = body['items']['item'];
            
            print('✅ 서울 도착정보 API 파싱 완료! 응답 데이터 발견');
            print('📄 버스 도착정보: $items');
            
            // items가 List인지 단일 Map인지 확인
            List<dynamic> itemList = [];
            if (items is List) {
              itemList = items;
            } else if (items is Map<String, dynamic>) {
              itemList = [items];
            }
            
            print('✅ 총 ${itemList.length}개의 버스 도착정보 발견');
            
            for (int i = 0; i < itemList.length; i++) {
              final item = itemList[i];
              try {
                // 실제 API 응답 구조에 맞게 직접 매핑
                final arrival = SeoulBusArrival(
                  nodeId: item['nodeid']?.toString() ?? '',
                  nodeNm: item['nodenm']?.toString() ?? '',
                  routeId: item['routeid']?.toString() ?? '',
                  routeNo: item['routeno']?.toString() ?? '',
                  routeTp: item['routetp']?.toString() ?? '',
                  arrPrevStationCnt: int.tryParse(item['arrprevstationcnt']?.toString() ?? '0') ?? 0,
                  vehicleTp: item['vehicletp']?.toString() ?? '',
                  arrTime: int.tryParse(item['arrtime']?.toString() ?? '0') ?? 0,
                );
                
                arrivals.add(arrival);
                
                print('서울 도착정보 ${i + 1}. ${arrival.routeNo}번');
                print('   - 노선ID: ${arrival.routeId}');
                print('   - 노선유형: ${arrival.routeTp}');
                print('   - 도착시간: ${arrival.arrTimeInMinutes}분 후 (${arrival.arrTime}초)');
                print('   - 남은 정류장: ${arrival.arrPrevStationCnt}개');
                print('   - 차량정보: ${arrival.vehicleTp}');
                print('');
              } catch (e) {
                print('❌ 서울 버스 도착정보 파싱 오류 ($i번째): $e');
                print('   - 원본 데이터: $item');
                continue;
              }
            }
          } else {
            print('⚠️ 서울 도착정보가 없거나 items.item 구조를 찾을 수 없습니다.');
            print('📄 body 구조: $body');
          }

          return arrivals;
        } else {
          print('❌ 서울 도착정보 API 응답 구조 오류');
          print('📄 전체 응답: ${response.body}');
          return [];
        }
      } else {
        print('❌ 서울 도착정보 API 호출 실패: ${response.statusCode}');
        print('📄 응답 내용: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ 서울 버스 도착정보 검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }
}