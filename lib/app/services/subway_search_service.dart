import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'subway_service.dart';

class SubwaySearchService {
  static String get _apiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';

  // REST API로 지하철역 검색
  static Future<List<SubwayStationInfo>> searchNearbyStations(LatLng center) async {
    if (_apiKey.isEmpty) {
      print('❌ 카카오 REST API 키가 없습니다.');
      return [];
    }

    try {
      print('🚇 지하철역 검색 시작: (${center.latitude}, ${center.longitude})');

      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/category.json'
        '?category_group_code=SW8'
        '&x=${center.longitude}'
        '&y=${center.latitude}'
        '&radius=500'
        '&sort=distance'
        '&page=1'
        '&size=15'
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $_apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List;
        
        print('✅ 지하철역 검색 완료: ${documents.length}개');
        
        return documents.map((station) => SubwayStationInfo.fromJson(station)).toList();
      } else {
        print('❌ API 호출 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ 지하철역 검색 오류: $e');
      return [];
    }
  }

  // 지하철 실시간 도착정보 조회
  static Future<List<SubwayArrival>> getArrivalInfo(String stationName) async {
    try {
      print('🚇 지하철 도착정보 조회: $stationName');
      final cleanStationName = _cleanStationName(stationName);
      return await SubwayService.getRealtimeArrival(cleanStationName);
    } catch (e) {
      print('❌ 지하철 도착정보 조회 실패: $e');
      return [];
    }
  }

  // 지하철역명 정리 (호선 정보 및 "역" 제거)
  static String _cleanStationName(String stationName) {
    String cleaned = stationName.split(' ')[0]; // 호선 정보 제거
    if (cleaned.endsWith('역')) {
      cleaned = cleaned.substring(0, cleaned.length - 1); // "역" 제거
    }
    return cleaned;
  }

  // 지하철 호선 색상 반환
  static Color getLineColor(String subwayId) {
    switch (subwayId) {
      case '1001': return const Color(0xFF0052A4); // 1호선
      case '1002': return const Color(0xFF00A84D); // 2호선
      case '1003': return const Color(0xFFEF7C1C); // 3호선
      case '1004': return const Color(0xFF00A5DE); // 4호선
      case '1005': return const Color(0xFF996CAC); // 5호선
      case '1006': return const Color(0xFFCD7C2F); // 6호선
      case '1007': return const Color(0xFF747F00); // 7호선
      case '1008': return const Color(0xFFEA545D); // 8호선
      case '1009': return const Color(0xFFBDB092); // 9호선
      case '1061': return const Color(0xFF0C8E72); // 중앙선
      case '1063': return const Color(0xFF77C4A3); // 경의중앙선
      case '1065': return const Color(0xFF0090D2); // 공항철도
      case '1067': return const Color(0xFF178C4B); // 경춘선
      case '1075': return const Color(0xFFEAB026); // 수인분당선
      case '1077': return const Color(0xFFD31145); // 신분당선
      case '1092': return const Color(0xFFB7CE63); // 우이신설선
      case '1093': return const Color(0xFF8FC31F); // 서해선
      case '1081': return const Color(0xFF003DA5); // 경강선
      case '1032': return const Color(0xFF9B1B7E); // GTX-A
      default: return Colors.grey;
    }
  }

  // 도착 상태 색상 반환
  static Color getArrivalColor(int arvlCd) {
    switch (arvlCd) {
      case 0: return Colors.red;        // 진입
      case 1: return Colors.orange;     // 도착
      case 2: return Colors.green;      // 출발
      case 3: return Colors.blue;       // 전역출발
      case 4: return Colors.purple;     // 전역진입
      case 5: return Colors.orange;     // 전역도착
      case 99: return Colors.grey;      // 운행중
      default: return Colors.black;
    }
  }

  // 열차 종류 색상 반환
  static Color getTrainTypeColor(String trainType) {
    switch (trainType) {
      case '급행': return Colors.red.shade600;
      case 'ITX': return Colors.purple.shade600;
      case '특급': return Colors.orange.shade600;
      case '직행': return Colors.blue.shade600;
      default: return Colors.grey.shade600;
    }
  }
}

// 지하철역 정보 모델
class SubwayStationInfo {
  final String id;
  final String placeName;
  final String addressName;
  final double latitude;
  final double longitude;
  final int distance;

  SubwayStationInfo({
    required this.id,
    required this.placeName,
    required this.addressName,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  factory SubwayStationInfo.fromJson(Map<String, dynamic> json) {
    return SubwayStationInfo(
      id: json['id'] ?? '',
      placeName: json['place_name'] ?? '',
      addressName: json['address_name'] ?? '',
      latitude: double.parse(json['y'].toString()),
      longitude: double.parse(json['x'].toString()),
      distance: int.tryParse(json['distance']?.toString() ?? '0') ?? 0,
    );
  }

  // 역명에서 "역" 제거
  String get cleanStationName {
    String cleaned = placeName.split(' ')[0];
    if (cleaned.endsWith('역')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }
}