import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoSubwayService {
  static const String _baseUrl = 'https://dapi.kakao.com/v2/local/search/category.json';
  static final String _restApiKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
  
  /// API 키 확인
  static bool get hasValidApiKey => _restApiKey.isNotEmpty;
  
  /// 지하철역 검색 (카테고리: SW8) - 페이지네이션으로 전체 결과 조회
  static Future<List<SubwayStation>> searchSubwayStations(String query) async {
    if (query.isEmpty) return [];
    
    // API 키 확인
    if (_restApiKey.isEmpty) {
      print('❌ 카카오 API 키가 설정되지 않았습니다!');
      print('📝 .env 파일에 KAKAO_REST_API_KEY를 추가해주세요.');
      return [];
    }
    
    try {
      List<dynamic> allDocuments = [];
      
      // 최대 3페이지까지 순차적으로 조회 (총 45개)
      for (int page = 1; page <= 3; page++) {
        final uri = Uri.parse(_baseUrl).replace(queryParameters: {
          'category_group_code': 'SW8', // 지하철역 카테고리
          'query': query,
          'size': '15', // 페이지당 15개
          'page': page.toString(), // 현재 페이지
        });
        
        print('🔍 지하철역 검색 요청 - 페이지 $page: $query');
        print('🌐 API URL: $uri');
        if (page == 1) {
          print('🔑 API Key: ${_restApiKey.substring(0, 8)}...');
        }
        
        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'KakaoAK $_restApiKey',
            'Content-Type': 'application/json',
          },
        );
        
        print('📊 페이지 $page 응답 상태: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> documents = data['documents'] ?? [];
          final Map<String, dynamic> meta = data['meta'] ?? {};
          
          print('✅ 페이지 $page 검색 결과: ${documents.length}개');
          
          // 현재 페이지의 결과를 전체 리스트에 추가
          allDocuments.addAll(documents);
          
          // 더 이상 결과가 없으면 중단
          final bool isEnd = meta['is_end'] ?? false;
          if (isEnd || documents.isEmpty) {
            print('📄 페이지 $page에서 검색 완료 (더 이상 결과 없음)');
            break;
          }
          
          // API 호출 간격 (너무 빠른 연속 호출 방지)
          if (page < 10) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
        } else {
          print('❌ 페이지 $page 검색 실패: ${response.statusCode}');
          print('📝 응답 내용: ${response.body}');
          // 첫 번째 페이지가 실패하면 중단, 이후 페이지는 계속 시도
          if (page == 1) {
            return [];
          }
          break;
        }
      }
      
      print('🎯 전체 검색 완료: 총 ${allDocuments.length}개 결과');
      
      final stations = allDocuments.map((doc) => SubwayStation.fromJson(doc)).toList();
      
      // 검색어와 관련있는 역만 필터링하고 정렬
      final filteredAndSortedStations = _filterAndSortByRelevance(stations, query);
      
      // 디버깅: 파싱된 역 데이터 출력
      if (filteredAndSortedStations.isNotEmpty) {
        print('🚇 파싱된 역 데이터 (필터링 및 정렬 후):');
        for (int i = 0; i < filteredAndSortedStations.length && i < 10; i++) {
          final station = filteredAndSortedStations[i];
          print('  ${i + 1}. 역명: ${station.stationName}, 주소: ${station.displayAddress}');
        }
      }
      
      return filteredAndSortedStations;
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
    
    // 검색어로 시작하는 역을 우선으로 정렬
    finalStations.sort((a, b) {
      final aStartsWith = a.stationName.toLowerCase().startsWith(lowerQuery);
      final bStartsWith = b.stationName.toLowerCase().startsWith(lowerQuery);
      
      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      
      // 둘 다 같은 조건이면 이름순으로 정렬
      return a.stationName.compareTo(b.stationName);
    });
    
    return finalStations;
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