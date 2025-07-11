import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xml/xml.dart';
import '../models/bus_models.dart';

class BusService {
  static const String _baseUrl = 'http://ws.bus.go.kr/api/rest';
  static String get _apiKey => dotenv.env['SEOUL_BUS_API_KEY'] ?? '';

  /// 현재 위치에서 가장 가까운 버스 정류장들을 조회
  static Future<List<BusStation>> findNearestBusStations(
    double latitude,
    double longitude,
  ) async {
    try {
      print('=== 버스 정류장 조회 시작 ===');
      print('위치: $latitude, $longitude');
      print('API 키: $_apiKey');
      
      // 좌표를 TM 좌표계로 변환 (대략적인 계산)
      final tmX = longitude * 111000; // 대략적인 변환
      final tmY = latitude * 111000;
      
      print('TM 좌표: $tmX, $tmY');
      
      final url = '$_baseUrl/stationinfo/getStationByPos'
          '?serviceKey=$_apiKey'
          '&tmX=$tmX'
          '&tmY=$tmY'
          '&radius=500';

      print('API URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');
      
      if (response.statusCode == 200) {
        // XML 응답 파싱
        final document = XmlDocument.parse(response.body);
        
        print('XML 파싱 완료');
        
        final msgHeader = document.findAllElements('msgHeader').first;
        final resultCode = msgHeader.findElements('resultCode').first.text;
        
        print('결과 코드: $resultCode');
        
        if (resultCode == '0') {
          final itemList = document.findAllElements('itemList');
          
          print('찾은 정류장 수: ${itemList.length}');
          
          final stations = itemList.map((item) {
            final stationId = item.findElements('arsId').first.text;
            final stationName = item.findElements('stNm').first.text;
            final tmX = double.tryParse(item.findElements('tmX').first.text) ?? 0.0;
            final tmY = double.tryParse(item.findElements('tmY').first.text) ?? 0.0;
            final dist = double.tryParse(item.findElements('dist').first.text) ?? 0.0;
            
            // TM 좌표를 WGS84로 대략 변환
            final stationLat = tmY / 111000;
            final stationLng = tmX / 111000;
            
            return BusStation(
              stationId: stationId,
              stationName: stationName,
              latitude: stationLat,
              longitude: stationLng,
              distance: dist,
              stationSeq: '',
            );
          }).toList()
            ..sort((a, b) => a.distance.compareTo(b.distance));
          
          print('정류장 정보 파싱 완료: ${stations.length}개');
          return stations;
        } else {
          final resultMessage = msgHeader.findElements('resultMsg').first.text;
          print('API 응답 오류: $resultMessage');
          throw Exception('API 응답 오류: $resultMessage');
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
        throw Exception('HTTP 오류: ${response.statusCode}');
      }

    } catch (e) {
      print('버스 정류장 조회 오류: $e');
      return [];
    }
  }

  /// 특정 정류장의 실시간 버스 도착 정보를 조회
  static Future<List<BusArrival>> getRealtimeBusArrival(String stationId) async {
    try {
      print('=== 버스 도착 정보 조회 시작 ===');
      print('정류장 ID: $stationId');
      
      final url = '$_baseUrl/stationinfo/getStationByUid'
          '?serviceKey=$_apiKey'
          '&arsId=$stationId';

      print('API URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');
      
      if (response.statusCode == 200) {
        // XML 응답 파싱
        final document = XmlDocument.parse(response.body);
        
        print('XML 파싱 완료');
        
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
          throw Exception('API 응답 오류: $resultMessage');
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
        throw Exception('HTTP 오류: ${response.statusCode}');
      }

    } catch (e) {
      print('버스 도착 정보 조회 오류: $e');
      return [];
    }
  }

  /// 버스 노선의 실시간 위치 정보를 조회 (제공된 API 활용)
  static Future<List<BusPosition>> getBusPositionsByRoute(
    String routeId,
    int startOrd,
    int endOrd,
  ) async {
    try {
      final url = '$_baseUrl/buspos/getBusPosByRouteSt'
          '?serviceKey=$_apiKey'
          '&busRouteId=$routeId'
          '&startOrd=$startOrd'
          '&endOrd=$endOrd'
          '&resultType=json';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['msgHeader']['resultCode'] == '0') {
          final List<dynamic> positions = data['msgBody']['itemList'] ?? [];
          
          return positions
              .map((position) => BusPosition.fromJson(position))
              .toList();
        }
      }
      
      throw Exception('버스 위치 정보 조회 실패');
    } catch (e) {
      print('버스 위치 정보 조회 오류: $e');
      return [];
    }
  }

  /// 버스 노선 정보를 조회
  static Future<BusRoute?> getBusRouteInfo(String routeId) async {
    try {
      final url = '$_baseUrl/busRouteInfo/getRouteInfo'
          '?serviceKey=$_apiKey'
          '&busRouteId=$routeId'
          '&resultType=json';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['msgHeader']['resultCode'] == '0') {
          final routeInfo = data['msgBody']['itemList']?[0];
          if (routeInfo != null) {
            return BusRoute.fromJson(routeInfo);
          }
        }
      }
      
      return null;
    } catch (e) {
      print('버스 노선 정보 조회 오류: $e');
      return null;
    }
  }

  /// 두 좌표 간의 거리를 계산 (미터 단위)
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
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
}

/// 버스 위치 정보 모델 (getBusPosByRouteSt API용)
class BusPosition {
  final String sectOrd;
  final String sectDist;
  final bool stopFlag;
  final String sectionId;
  final String dataTm;
  final String tmX;
  final String tmY;
  final String vehId;
  final String plainNo;
  final String busType;
  final String lastStnId;
  final String posX;
  final String posY;
  final String routeId;
  final String congetion;

  BusPosition({
    required this.sectOrd,
    required this.sectDist,
    required this.stopFlag,
    required this.sectionId,
    required this.dataTm,
    required this.tmX,
    required this.tmY,
    required this.vehId,
    required this.plainNo,
    required this.busType,
    required this.lastStnId,
    required this.posX,
    required this.posY,
    required this.routeId,
    required this.congetion,
  });

  factory BusPosition.fromJson(Map<String, dynamic> json) {
    return BusPosition(
      sectOrd: json['sectOrd']?.toString() ?? '',
      sectDist: json['sectDist']?.toString() ?? '',
      stopFlag: json['stopFlag']?.toString() == '1',
      sectionId: json['sectionId']?.toString() ?? '',
      dataTm: json['dataTm']?.toString() ?? '',
      tmX: json['tmX']?.toString() ?? '',
      tmY: json['tmY']?.toString() ?? '',
      vehId: json['vehId']?.toString() ?? '',
      plainNo: json['plainNo']?.toString() ?? '',
      busType: json['busType']?.toString() ?? '',
      lastStnId: json['lastStnId']?.toString() ?? '',
      posX: json['posX']?.toString() ?? '',
      posY: json['posY']?.toString() ?? '',
      routeId: json['routeId']?.toString() ?? '',
      congetion: json['congetion']?.toString() ?? '',
    );
  }

  bool get isLowFloor => busType == '1';
  
  String get congestionLevel {
    switch (congetion) {
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
}