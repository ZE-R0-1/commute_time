import 'package:commute_time_app/app/services/seoul_bus_service.dart';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'gyeonggi_bus_service.dart';
import 'bus_arrival_service.dart';

class BusSearchService {
  // 근처 버스정류장 검색 (경기도 + 서울)
  static Future<BusSearchResult> searchNearbyBusStops(LatLng center) async {
    try {
      print('🚌 버스정류장 통합 검색 시작: (${center.latitude}, ${center.longitude})');

      final results = await Future.wait([
        _searchGyeonggiBusStops(center),
        _searchSeoulBusStops(center),
      ]);

      final gyeonggiBusStops = results[0] as List<GyeonggiBusStop>;
      final seoulBusStops = results[1] as List<SeoulBusStop>;

      print('✅ 버스정류장 검색 완료: 경기 ${gyeonggiBusStops.length}개, 서울 ${seoulBusStops.length}개');

      return BusSearchResult(
        gyeonggiBusStops: gyeonggiBusStops,
        seoulBusStops: seoulBusStops,
      );
    } catch (e) {
      print('❌ 버스정류장 검색 오류: $e');
      return BusSearchResult(
        gyeonggiBusStops: [],
        seoulBusStops: [],
      );
    }
  }

  // 경기도 버스정류장 검색
  static Future<List<GyeonggiBusStop>> _searchGyeonggiBusStops(LatLng center) async {
    try {
      return await GyeonggiBusService.getBusStopsByLocation(
        center.latitude,
        center.longitude,
        radius: 500,
      );
    } catch (e) {
      print('❌ 경기도 버스정류장 검색 오류: $e');
      return [];
    }
  }

  // 서울 버스정류장 검색
  static Future<List<SeoulBusStop>> _searchSeoulBusStops(LatLng center) async {
    try {
      return await SeoulBusService.getBusStopsByLocation(
        center.latitude,
        center.longitude,
        radius: 500,
      );
    } catch (e) {
      print('❌ 서울 버스정류장 검색 오류: $e');
      return [];
    }
  }

  // 경기도 버스 도착정보 조회
  static Future<List<BusArrivalInfo>> getGyeonggiBusArrivalInfo(String stationId) async {
    try {
      return await BusArrivalService.getBusArrivalInfo(stationId);
    } catch (e) {
      print('❌ 경기도 버스 도착정보 조회 실패: $e');
      return [];
    }
  }

  // 서울 버스 도착정보 조회
  static Future<List<SeoulBusArrival>> getSeoulBusArrivalInfo(String stationId) async {
    try {
      return await SeoulBusService.getBusArrivalInfo('23', stationId);
    } catch (e) {
      print('❌ 서울 버스 도착정보 조회 실패: $e');
      return [];
    }
  }

  // 버스 유형별 색상 반환 (경기도)
  static Color getBusTypeColor(String routeTypeName) {
    switch (routeTypeName) {
      case '직행좌석': return Colors.red;
      case '좌석': return Colors.blue;
      case '일반': return Colors.green;
      case '광역급행': return Colors.purple;
      default: return Colors.grey;
    }
  }

  // 서울 버스 유형별 색상 반환
  static Color getSeoulBusTypeColor(String routeType) {
    switch (routeType) {
      case '1': return Colors.orange;  // 공항
      case '2': return Colors.green;   // 마을
      case '3': return Colors.blue;    // 간선
      case '4': return Colors.green;   // 지선
      case '5': return Colors.purple;  // 순환
      case '6': return Colors.red;     // 광역
      case '7': return Colors.cyan;    // 인천
      case '8': return Colors.amber;   // 경기
      default: return Colors.grey;
    }
  }

  // 서울 버스 유형명 반환
  static String getSeoulBusTypeName(String routeType) {
    switch (routeType) {
      case '1': return '공항';
      case '2': return '마을';
      case '3': return '간선';
      case '4': return '지선';
      case '5': return '순환';
      case '6': return '광역';
      case '7': return '인천';
      case '8': return '경기';
      default: return '일반';
    }
  }
}

// 버스 검색 결과 모델
class BusSearchResult {
  final List<GyeonggiBusStop> gyeonggiBusStops;
  final List<SeoulBusStop> seoulBusStops;

  BusSearchResult({
    required this.gyeonggiBusStops,
    required this.seoulBusStops,
  });

  int get totalCount => gyeonggiBusStops.length + seoulBusStops.length;
  bool get isEmpty => totalCount == 0;
  bool get isNotEmpty => totalCount > 0;
}