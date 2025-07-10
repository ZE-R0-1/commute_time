import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoSubwayService {
  static const String _baseUrl = 'https://dapi.kakao.com/v2/local/search/category.json';
  static final String _restApiKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
  
  /// API 키 확인
  static bool get hasValidApiKey => _restApiKey.isNotEmpty;
  
  /// 지하철역 검색 (카테고리: SW8)
  static Future<List<SubwayStation>> searchSubwayStations(String query) async {
    if (query.isEmpty) return [];
    
    // API 키 확인
    if (_restApiKey.isEmpty) {
      print('❌ 카카오 API 키가 설정되지 않았습니다!');
      print('📝 .env 파일에 KAKAO_REST_API_KEY를 추가해주세요.');
      return [];
    }
    
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'category_group_code': 'SW8', // 지하철역 카테고리
        'query': query,
        'size': '15', // 최대 15개 결과
      });
      
      print('🔍 지하철역 검색 요청: $query');
      print('🌐 API URL: $uri');
      print('🔑 API Key: ${_restApiKey.substring(0, 8)}...');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'KakaoAK $_restApiKey',
          'Content-Type': 'application/json',
        },
      );
      
      print('📊 응답 상태: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> documents = data['documents'] ?? [];
        
        print('✅ 검색 결과: ${documents.length}개');
        
        // 디버깅: 첫 번째 결과 데이터 출력
        if (documents.isNotEmpty) {
          print('📝 첫 번째 결과: ${documents.first}');
        }
        
        final stations = documents.map((doc) => SubwayStation.fromJson(doc)).toList();
        
        // 검색어와 관련있는 역만 필터링하고 정렬
        final filteredAndSortedStations = _filterAndSortByRelevance(stations, query);
        
        // 디버깅: 파싱된 역 데이터 출력
        if (filteredAndSortedStations.isNotEmpty) {
          print('🚇 파싱된 역 데이터 (필터링 및 정렬 후):');
          for (int i = 0; i < filteredAndSortedStations.length && i < 5; i++) {
            final station = filteredAndSortedStations[i];
            print('  ${i + 1}. 역명: ${station.stationName}, 주소: ${station.displayAddress}');
          }
        }
        
        return filteredAndSortedStations;
      } else {
        print('❌ 지하철역 검색 실패: ${response.statusCode}');
        print('📝 응답 내용: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ 지하철역 검색 오류: $e');
      return [];
    }
  }
  
  /// 위치 기반 근처 지하철역 검색
  static Future<List<SubwayStation>> searchNearbySubwayStations({
    required double latitude,
    required double longitude,
    int radius = 1000, // 반경 1km
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'category_group_code': 'SW8',
        'x': longitude.toString(),
        'y': latitude.toString(),
        'radius': radius.toString(),
        'size': '10',
      });
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'KakaoAK $_restApiKey',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> documents = data['documents'] ?? [];
        
        return documents.map((doc) => SubwayStation.fromJson(doc)).toList();
      } else {
        print('근처 지하철역 검색 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('근처 지하철역 검색 오류: $e');
      return [];
    }
  }
  
  /// 검색어와 관련있는 역만 필터링하고 정렬
  static List<SubwayStation> _filterAndSortByRelevance(List<SubwayStation> stations, String query) {
    // 검색어를 소문자로 변환
    final lowerQuery = query.toLowerCase();
    
    // 검색어와 관련있는 역만 필터링
    final relevantStations = stations.where((station) {
      final lowerStationName = station.stationName.toLowerCase();
      
      // 검색어가 역명에 포함되어 있는지 확인
      return lowerStationName.contains(lowerQuery);
    }).toList();
    
    print('🔍 필터링 결과: 전체 ${stations.length}개 → 관련 ${relevantStations.length}개');
    
    // 관련있는 역이 없으면 원래 검색 결과를 그대로 반환하되 정렬은 적용
    List<SubwayStation> finalStations;
    if (relevantStations.isEmpty) {
      print('⚠️ 관련 역이 없어 전체 결과를 반환합니다.');
      finalStations = List.from(stations);
    } else {
      finalStations = relevantStations;
    }
    
    // 각 역에 대한 점수 계산 및 정렬
    finalStations.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a.stationName.toLowerCase(), lowerQuery);
      final scoreB = _calculateRelevanceScore(b.stationName.toLowerCase(), lowerQuery);
      
      return scoreB.compareTo(scoreA); // 점수가 높은 순으로 정렬
    });
    
    return finalStations;
  }
  
  /// 검색어와의 일치도에 따라 결과 정렬 (기존 함수 유지)
  static List<SubwayStation> _sortByRelevance(List<SubwayStation> stations, String query) {
    // 검색어를 소문자로 변환
    final lowerQuery = query.toLowerCase();
    
    // 각 역에 대한 점수 계산 및 정렬
    stations.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a.stationName.toLowerCase(), lowerQuery);
      final scoreB = _calculateRelevanceScore(b.stationName.toLowerCase(), lowerQuery);
      
      return scoreB.compareTo(scoreA); // 점수가 높은 순으로 정렬
    });
    
    return stations;
  }
  
  /// 검색어와 역명의 일치도 점수 계산
  static int _calculateRelevanceScore(String stationName, String query) {
    int score = 0;
    
    // 1. 정확히 시작하는 경우 (가장 높은 점수)
    if (stationName.startsWith(query)) {
      score += 1000;
    }
    
    // 2. 포함하는 경우
    if (stationName.contains(query)) {
      score += 500;
    }
    
    // 3. 공통 문자 개수에 따른 점수
    int commonChars = 0;
    for (int i = 0; i < query.length && i < stationName.length; i++) {
      if (query[i] == stationName[i]) {
        commonChars++;
      }
    }
    score += commonChars * 100;
    
    // 4. 역명이 짧을수록 더 관련성이 높다고 판단
    score += (20 - stationName.length).clamp(0, 20);
    
    return score;
  }
}

/// 지하철역 데이터 모델
class SubwayStation {
  final String id;
  final String stationName;
  final String placeName;
  final String roadAddressName;
  final String addressName;
  final double latitude;
  final double longitude;
  final String phone;
  final String distance;
  
  SubwayStation({
    required this.id,
    required this.stationName,
    required this.placeName,
    required this.roadAddressName,
    required this.addressName,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.distance,
  });
  
  factory SubwayStation.fromJson(Map<String, dynamic> json) {
    // 디버깅: JSON 데이터 파싱 확인
    final placeName = json['place_name'] ?? '';
    final stationName = _extractStationName(placeName);
    
    print('🔄 JSON 파싱: $placeName → $stationName');
    
    return SubwayStation(
      id: json['id'] ?? '',
      stationName: stationName,
      placeName: placeName,
      roadAddressName: json['road_address_name'] ?? '',
      addressName: json['address_name'] ?? '',
      latitude: double.tryParse(json['y'] ?? '0') ?? 0.0,
      longitude: double.tryParse(json['x'] ?? '0') ?? 0.0,
      phone: json['phone'] ?? '',
      distance: json['distance'] ?? '0',
    );
  }
  
  /// 역명 정리 (호선 정보 포함하여 반환)
  static String _extractStationName(String placeName) {
    // 호선 정보를 포함하여 반환하되, '지하철'만 제거
    final stationName = placeName
        .replaceAll('지하철', '')
        .trim();
    
    return stationName.isNotEmpty ? stationName : placeName;
  }
  
  /// 거리 표시용 텍스트
  String get distanceText {
    final dist = int.tryParse(distance) ?? 0;
    if (dist == 0) return '';
    if (dist < 1000) return '${dist}m';
    return '${(dist / 1000).toStringAsFixed(1)}km';
  }
  
  /// 표시용 주소 (도로명 우선)
  String get displayAddress {
    return roadAddressName.isNotEmpty ? roadAddressName : addressName;
  }
  
  @override
  String toString() {
    return 'SubwayStation(stationName: $stationName, address: $displayAddress)';
  }
}