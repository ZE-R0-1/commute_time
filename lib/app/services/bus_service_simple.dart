import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xml/xml.dart';
import '../models/bus_models.dart';

class SimpleBusService {
  static String get _busApiKey => dotenv.env['SEOUL_BUS_API_KEY'] ?? '';
  static String get _busApiUrl => dotenv.env['SEOUL_BUS_API_URL'] ?? '';
  static String get _kakaoApiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';
  
  // 추가 API 엔드포인트들
  static String get _busRouteStationUrl => '$_busApiUrl/busRouteInfo/getStaionByRoute';
  static String get _stationRouteUrl => '$_busApiUrl/stationinfo/getRouteByStation';
  static String get _stationSearchUrl => '$_busApiUrl/stationinfo/getStationByName';

  /// 1단계: 카카오 API로 근처 버스 정류장 찾기
  static Future<List<BusStation>> findNearestBusStations(
    double latitude,
    double longitude,
  ) async {
    try {
      print('=== 카카오 API로 버스 정류장 검색 ===');
      print('위치: $latitude, $longitude');
      
      // 카카오 API로 버스 정류장 검색
      final url = 'https://dapi.kakao.com/v2/local/search/category.json'
          '?category_group_code=BU8' // 버스 정류장
          '&x=$longitude'
          '&y=$latitude'
          '&radius=1000' // 1km 반경
          '&sort=distance'
          '&size=5'; // 상위 5개
      
      print('카카오 API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'KakaoAK $_kakaoApiKey',
        },
      );
      
      print('카카오 API 응답 코드: ${response.statusCode}');
      print('카카오 API 응답: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> documents = data['documents'] ?? [];
        
        print('찾은 버스 정류장 수: ${documents.length}');
        
        final List<BusStation> stations = [];
        
        for (final doc in documents) {
          final placeName = doc['place_name'] ?? '';
          final distance = double.tryParse(doc['distance'] ?? '0') ?? 0.0;
          final stationLat = double.tryParse(doc['y'] ?? '0') ?? 0.0;
          final stationLng = double.tryParse(doc['x'] ?? '0') ?? 0.0;
          
          print('정류장 발견: $placeName (${distance}m)');
          
          // 2단계: 정류장명으로 정류장 ID 찾기
          final stationId = await findStationIdByName(placeName);
          
          if (stationId != null) {
            stations.add(BusStation(
              stationId: stationId,
              stationName: placeName,
              latitude: stationLat,
              longitude: stationLng,
              distance: distance,
              stationSeq: '',
            ));
          }
        }
        
        print('유효한 버스 정류장: ${stations.length}개');
        return stations;
      } else {
        print('카카오 API 오류: ${response.statusCode}');
        return _getDummyBusStations(latitude, longitude);
      }
    } catch (e) {
      print('버스 정류장 조회 오류: $e');
      return _getDummyBusStations(latitude, longitude);
    }
  }
  
  /// 정류장명으로 정류장 ID와 좌표 찾기 (public으로 변경)
  static Future<BusStation?> findStationByName(String stationName) async {
    try {
      print('정류장 정보 검색: $stationName');
      
      // 1단계: 카카오 API로 정류장 좌표 찾기
      final coordinates = await _findStationCoordinates(stationName);
      
      // 2단계: 서울 버스 API로 정류장 ID 찾기  
      final stationId = await findStationIdByName(stationName);
      
      if (coordinates != null && stationId != null) {
        return BusStation(
          stationId: stationId,
          stationName: stationName,
          latitude: coordinates['lat']!,
          longitude: coordinates['lng']!,
          distance: 0.0,
          stationSeq: '',
        );
      }
      
      return null;
    } catch (e) {
      print('정류장 정보 검색 오류: $e');
      return null;
    }
  }

  /// 카카오 API로 정류장 좌표 찾기
  static Future<Map<String, double>?> _findStationCoordinates(String stationName) async {
    try {
      print('카카오 API로 정류장 좌표 검색: $stationName');
      
      // 카카오 키워드 검색 API
      final url = 'https://dapi.kakao.com/v2/local/search/keyword.json'
          '?query=${Uri.encodeComponent(stationName + ' 버스정류장')}'
          '&category_group_code=BU8' // 버스 정류장
          '&size=1'; // 가장 유사한 1개만
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'KakaoAK $_kakaoApiKey',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> documents = data['documents'] ?? [];
        
        if (documents.isNotEmpty) {
          final doc = documents.first;
          final lat = double.tryParse(doc['y'] ?? '0') ?? 0.0;
          final lng = double.tryParse(doc['x'] ?? '0') ?? 0.0;
          
          if (lat != 0.0 && lng != 0.0) {
            print('좌표 발견: $stationName ($lat, $lng)');
            return {'lat': lat, 'lng': lng};
          }
        }
      }
      
      return null;
    } catch (e) {
      print('정류장 좌표 검색 오류: $e');
      return null;
    }
  }

  /// 정류장명으로 정류장 ID만 찾기 (기존 기능 유지)
  static Future<String?> findStationIdByName(String stationName) async {
    try {
      print('정류장 ID 검색: $stationName');
      
      // 정류장명 검색 API
      final url = '$_busApiUrl/stationinfo/getStationByName'
          '?serviceKey=$_busApiKey'
          '&stSrch=${Uri.encodeComponent(stationName)}';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final msgHeader = document.findAllElements('msgHeader').first;
        final resultCode = msgHeader.findElements('resultCode').first.text;
        
        if (resultCode == '0') {
          final itemList = document.findAllElements('itemList');
          if (itemList.isNotEmpty) {
            final stationId = itemList.first.findElements('arsId').first.text;
            print('정류장 ID 발견: $stationId');
            return stationId;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('정류장 ID 검색 오류: $e');
      return null;
    }
  }

  /// 3단계: 실시간 버스 도착 정보 조회 (서울 버스 API)
  static Future<List<BusArrival>> getRealtimeBusArrival(String stationId) async {
    try {
      print('=== 실시간 버스 도착 정보 조회 ===');
      print('정류장 ID: $stationId');
      
      // 더미 데이터 ID인 경우 더미 데이터 반환
      if (stationId == '12345' || stationId == '67890' || stationId == '11111') {
        return _getDummyBusArrivals(stationId);
      }
      
      final url = '$_busApiUrl/stationinfo/getStationByUid'
          '?serviceKey=$_busApiKey'
          '&arsId=$stationId';

      print('버스 도착 정보 API URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');
      
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final msgHeader = document.findAllElements('msgHeader').first;
        final resultCode = msgHeader.findElements('resultCode').first.text;
        
        print('결과 코드: $resultCode');
        
        if (resultCode == '0') {
          final itemList = document.findAllElements('itemList');
          
          print('찾은 도착 정보 수: ${itemList.length}');
          
          final arrivals = itemList.map((item) {
            final routeId = item.findElements('busRouteId').isNotEmpty
                ? item.findElements('busRouteId').first.text
                : '';
            final routeName = item.findElements('rtNm').isNotEmpty
                ? item.findElements('rtNm').first.text
                : '';
            final routeType = item.findElements('routeType').isNotEmpty
                ? item.findElements('routeType').first.text
                : '';
            final arrivalTime1 = item.findElements('traTime1').isNotEmpty
                ? int.tryParse(item.findElements('traTime1').first.text) ?? 0
                : 0;
            final arrivalTime2 = item.findElements('traTime2').isNotEmpty
                ? int.tryParse(item.findElements('traTime2').first.text) ?? 0
                : 0;
            final direction = item.findElements('adirection').isNotEmpty
                ? item.findElements('adirection').first.text
                : '';
            final busType = item.findElements('busType1').isNotEmpty
                ? item.findElements('busType1').first.text
                : '0';
            final congestion = item.findElements('reride_Num1').isNotEmpty
                ? item.findElements('reride_Num1').first.text
                : '0';
            
            return BusArrival(
              routeId: routeId,
              routeName: routeName,
              routeType: _getRouteTypeFromCode(routeType),
              arrivalTime1: arrivalTime1,
              arrivalTime2: arrivalTime2,
              direction: direction,
              isLowFloor: busType == '1',
              congestion: _getCongestionFromCode(congestion),
              stationSeq: '',
            );
          }).toList()
            ..removeWhere((arrival) => arrival.arrivalTime1 == 0 && arrival.arrivalTime2 == 0)
            ..sort((a, b) => a.arrivalTime1.compareTo(b.arrivalTime1));
          
          print('도착 정보 파싱 완료: ${arrivals.length}개');
          return arrivals;
        } else {
          final resultMessage = msgHeader.findElements('resultMsg').first.text;
          print('API 응답 오류: $resultMessage');
          return _getDummyBusArrivals(stationId);
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
        return _getDummyBusArrivals(stationId);
      }
    } catch (e) {
      print('버스 도착 정보 조회 오류: $e');
      return _getDummyBusArrivals(stationId);
    }
  }
  
  /// 더미 버스 정류장 (백업용)
  static List<BusStation> _getDummyBusStations(double latitude, double longitude) {
    return [
      BusStation(
        stationId: '12345',
        stationName: '디지털미디어시티역버스정류장',
        latitude: latitude + 0.002,
        longitude: longitude + 0.001,
        distance: 250.0,
        stationSeq: '1',
      ),
      BusStation(
        stationId: '67890',
        stationName: '월드컵공원역버스정류장',
        latitude: latitude - 0.001,
        longitude: longitude + 0.002,
        distance: 380.0,
        stationSeq: '2',
      ),
      BusStation(
        stationId: '11111',
        stationName: '상암동버스정류장',
        latitude: latitude + 0.001,
        longitude: longitude - 0.001,
        distance: 420.0,
        stationSeq: '3',
      ),
    ];
  }
  
  /// 더미 버스 도착 정보 (백업용)
  static List<BusArrival> _getDummyBusArrivals(String stationId) {
    switch (stationId) {
      case '12345':
        return [
          BusArrival(
            routeId: '100100001',
            routeName: '271',
            routeType: '간선',
            arrivalTime1: 180, // 3분
            arrivalTime2: 720, // 12분
            direction: '서울역 방면',
            isLowFloor: true,
            congestion: '보통',
            stationSeq: '1',
          ),
          BusArrival(
            routeId: '100100002',
            routeName: '7011',
            routeType: '광역',
            arrivalTime1: 420, // 7분
            arrivalTime2: 900, // 15분
            direction: '강남역 방면',
            isLowFloor: false,
            congestion: '여유',
            stationSeq: '1',
          ),
        ];
      case '67890':
        return [
          BusArrival(
            routeId: '100100003',
            routeName: '6715',
            routeType: '지선',
            arrivalTime1: 300, // 5분
            arrivalTime2: 600, // 10분
            direction: '합정역 방면',
            isLowFloor: true,
            congestion: '혼잡',
            stationSeq: '2',
          ),
        ];
      case '11111':
        return [
          BusArrival(
            routeId: '100100004',
            routeName: '마을버스 01',
            routeType: '마을',
            arrivalTime1: 240, // 4분
            arrivalTime2: 480, // 8분
            direction: '순환',
            isLowFloor: false,
            congestion: '정보없음',
            stationSeq: '3',
          ),
        ];
      default:
        return [];
    }
  }
  
  static String _getRouteTypeFromCode(String code) {
    switch (code) {
      case '1':
        return '공항';
      case '2':
        return '마을';
      case '3':
        return '간선';
      case '4':
        return '지선';
      case '5':
        return '순환';
      case '6':
        return '광역';
      case '7':
        return '인천';
      case '8':
        return '경기';
      case '9':
        return '폐지';
      case '0':
        return '공용';
      default:
        return '일반';
    }
  }
  
  static String _getCongestionFromCode(String code) {
    switch (code) {
      case '0':
        return '정보없음';
      case '3':
        return '여유';
      case '4':
        return '보통';
      case '5':
        return '혼잡';
      case '6':
        return '매우혼잡';
      default:
        return '정보없음';
    }
  }
  
  /// 🆕 버스 노선별 정류장 정보 조회 (getStaionByRoute)
  static Future<List<BusStation>> getStationsByRoute(String routeId) async {
    try {
      print('=== 버스 노선별 정류장 정보 조회 ===');
      print('노선 ID: $routeId');
      
      final url = '$_busRouteStationUrl'
          '?serviceKey=$_busApiKey'
          '&busRouteId=$routeId';
      
      final response = await http.get(Uri.parse(url));
      
      print('응답 상태: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final msgHeader = document.findAllElements('msgHeader').first;
        final resultCode = msgHeader.findElements('resultCode').first.text;
        
        if (resultCode == '0') {
          final itemList = document.findAllElements('itemList');
          
          final stations = itemList.map((item) {
            final stationId = item.findElements('arsId').isNotEmpty
                ? item.findElements('arsId').first.text
                : '';
            final stationName = item.findElements('stationNm').isNotEmpty
                ? item.findElements('stationNm').first.text
                : '';
            final stationSeq = item.findElements('seq').isNotEmpty
                ? item.findElements('seq').first.text
                : '';
            final latitude = item.findElements('gpsY').isNotEmpty
                ? double.tryParse(item.findElements('gpsY').first.text) ?? 0.0
                : 0.0;
            final longitude = item.findElements('gpsX').isNotEmpty
                ? double.tryParse(item.findElements('gpsX').first.text) ?? 0.0
                : 0.0;
            
            return BusStation(
              stationId: stationId,
              stationName: stationName,
              latitude: latitude,
              longitude: longitude,
              distance: 0.0,
              stationSeq: stationSeq,
            );
          }).toList();
          
          print('노선별 정류장 조회 완료: ${stations.length}개');
          return stations;
        }
      }
      
      return [];
    } catch (e) {
      print('노선별 정류장 조회 오류: $e');
      return [];
    }
  }
  
  /// 🆕 정류장별 경유 버스 정보 조회 (getRouteByStation)
  static Future<List<BusArrival>> getRoutesByStation(String stationId) async {
    try {
      print('=== 정류장별 경유 버스 정보 조회 ===');
      print('정류장 ID: $stationId');
      
      final url = '$_stationRouteUrl'
          '?serviceKey=$_busApiKey'
          '&arsId=$stationId';
      
      final response = await http.get(Uri.parse(url));
      
      print('응답 상태: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final msgHeader = document.findAllElements('msgHeader').first;
        final resultCode = msgHeader.findElements('resultCode').first.text;
        
        if (resultCode == '0') {
          final itemList = document.findAllElements('itemList');
          
          final routes = itemList.map((item) {
            final routeId = item.findElements('busRouteId').isNotEmpty
                ? item.findElements('busRouteId').first.text
                : '';
            final routeName = item.findElements('busRouteNm').isNotEmpty
                ? item.findElements('busRouteNm').first.text
                : '';
            final routeType = item.findElements('routeType').isNotEmpty
                ? item.findElements('routeType').first.text
                : '';
            final direction = item.findElements('stDir').isNotEmpty
                ? item.findElements('stDir').first.text
                : '';
            
            return BusArrival(
              routeId: routeId,
              routeName: routeName,
              routeType: _getRouteTypeFromCode(routeType),
              arrivalTime1: 0, // 실시간 정보는 별도 조회 필요
              arrivalTime2: 0,
              direction: direction,
              isLowFloor: false,
              congestion: '정보없음',
              stationSeq: '',
            );
          }).toList();
          
          print('정류장별 경유 버스 조회 완료: ${routes.length}개');
          return routes;
        }
      }
      
      return [];
    } catch (e) {
      print('정류장별 경유 버스 조회 오류: $e');
      return [];
    }
  }
  
  /// 🆕 향상된 정류장별 실시간 정보 (경유 버스 정보 + 실시간 도착 정보 결합)
  static Future<List<BusArrival>> getEnhancedRealtimeInfo(String stationId) async {
    try {
      print('=== 향상된 정류장별 실시간 정보 조회 ===');
      
      // 1단계: 정류장별 경유 버스 정보 조회
      final availableRoutes = await getRoutesByStation(stationId);
      
      // 2단계: 실시간 도착 정보 조회
      final realtimeInfo = await getRealtimeBusArrival(stationId);
      
      // 3단계: 두 정보를 결합
      final enhancedInfo = <BusArrival>[];
      
      for (final route in availableRoutes) {
        // 실시간 정보에서 해당 노선 찾기
        final realtimeRoute = realtimeInfo.firstWhere(
          (rt) => rt.routeName == route.routeName,
          orElse: () => BusArrival(
            routeId: route.routeId,
            routeName: route.routeName,
            routeType: route.routeType,
            arrivalTime1: 0,
            arrivalTime2: 0,
            direction: route.direction,
            isLowFloor: false,
            congestion: '정보없음',
            stationSeq: '',
          ),
        );
        
        enhancedInfo.add(realtimeRoute);
      }
      
      print('향상된 실시간 정보 조회 완료: ${enhancedInfo.length}개');
      return enhancedInfo;
      
    } catch (e) {
      print('향상된 실시간 정보 조회 오류: $e');
      return await getRealtimeBusArrival(stationId); // 폴백
    }
  }
  
  /// 🆕 특정 노선의 정류장 순서 정보 조회 (경로 최적화용)
  static Future<List<BusStation>> getRouteStationSequence(String routeId) async {
    try {
      final stations = await getStationsByRoute(routeId);
      
      // 정류장 순서대로 정렬
      stations.sort((a, b) {
        final seqA = int.tryParse(a.stationSeq) ?? 0;
        final seqB = int.tryParse(b.stationSeq) ?? 0;
        return seqA.compareTo(seqB);
      });
      
      print('노선 $routeId 정류장 순서 조회 완료: ${stations.length}개');
      return stations;
      
    } catch (e) {
      print('노선 정류장 순서 조회 오류: $e');
      return [];
    }
  }
}