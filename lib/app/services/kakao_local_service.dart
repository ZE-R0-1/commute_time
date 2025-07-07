import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoLocalService {
  static String get _baseUrl => dotenv.env['KAKAO_API_URL'] ?? 'https://dapi.kakao.com/v2/local';
  static String get _apiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';

  // 현재 위치 기반 지하철역 검색
  static Future<List<SubwayStation>> findNearbySubwayStations(
      double latitude, double longitude, {int radius = 2000}) async {
    try {
      final url = '$_baseUrl/search/category.json';
      
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {
          'category_group_code': 'SW8', // 지하철역 카테고리
          'x': longitude.toString(),
          'y': latitude.toString(),
          'radius': radius.toString(), // 반경 (미터)
          'sort': 'distance', // 거리순 정렬
          'size': '15', // 최대 15개 결과
        }),
        headers: {
          'Authorization': 'KakaoAK $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      print('카카오 API 요청 URL: ${response.request?.url}');
      print('카카오 API 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('카카오 API 응답 본문 (첫 500자): ${responseBody.length > 500 ? responseBody.substring(0, 500) : responseBody}');
        
        final jsonData = json.decode(responseBody);
        
        // 메타 정보 확인
        final meta = jsonData['meta'];
        print('검색 결과 개수: ${meta['total_count']}');
        
        // 문서 파싱
        final documents = jsonData['documents'] as List;
        
        return documents.map((doc) => SubwayStation.fromJson(doc)).toList();
      } else {
        throw Exception('카카오 API 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('카카오 지하철역 검색 오류: $e');
      return [];
    }
  }

  // 키워드로 지하철역 검색
  static Future<List<SubwayStation>> searchSubwayStations(
      String keyword, double latitude, double longitude) async {
    try {
      final url = '$_baseUrl/search/keyword.json';
      
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {
          'query': '$keyword 지하철역',
          'category_group_code': 'SW8',
          'x': longitude.toString(),
          'y': latitude.toString(),
          'radius': '20000', // 20km 반경
          'sort': 'distance',
          'size': '15',
        }),
        headers: {
          'Authorization': 'KakaoAK $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      print('카카오 키워드 검색 API 요청 URL: ${response.request?.url}');
      print('카카오 키워드 검색 API 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('카카오 키워드 검색 API 응답 본문 (첫 500자): ${responseBody.length > 500 ? responseBody.substring(0, 500) : responseBody}');
        
        final jsonData = json.decode(responseBody);
        
        final meta = jsonData['meta'];
        print('키워드 검색 결과 개수: ${meta['total_count']}');
        
        final documents = jsonData['documents'] as List;
        
        return documents.map((doc) => SubwayStation.fromJson(doc)).toList();
      } else {
        throw Exception('카카오 키워드 검색 API 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('카카오 키워드 검색 오류: $e');
      return [];
    }
  }

  // 가장 가까운 지하철역 찾기 (단일 API 호출로 최적화)
  static Future<SubwayStation?> findNearestSubwayStation(
      double latitude, double longitude) async {
    try {
      print('🚇 카카오 API로 가장 가까운 지하철역 검색 시작');
      
      final url = '$_baseUrl/search/category.json';
      
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {
          'category_group_code': 'SW8', // 지하철역 카테고리
          'x': longitude.toString(),
          'y': latitude.toString(),
          'radius': '2000', // 2km 반경
          'sort': 'distance', // 거리순 정렬
          'size': '1', // 가장 가까운 1개만
        }),
        headers: {
          'Authorization': 'KakaoAK $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      print('카카오 API 요청 URL: ${response.request?.url}');
      print('카카오 API 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('카카오 API 응답: ${responseBody.length > 300 ? responseBody.substring(0, 300) : responseBody}');
        
        final jsonData = json.decode(responseBody);
        
        // 메타 정보 확인
        final meta = jsonData['meta'];
        final totalCount = meta['total_count'] ?? 0;
        print('검색 결과 개수: $totalCount');
        
        // 문서 파싱
        final documents = jsonData['documents'] as List;
        
        if (documents.isNotEmpty) {
          final station = SubwayStation.fromJson(documents.first);
          print('✅ 가장 가까운 지하철역: ${station.placeName} (${station.distanceText})');
          return station;
        } else {
          print('❌ 2km 반경 내에 지하철역이 없습니다');
          return null;
        }
      } else {
        throw Exception('카카오 API 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 가장 가까운 지하철역 찾기 오류: $e');
      return null;
    }
  }
}

// 지하철역 정보 모델
class SubwayStation {
  final String id;
  final String placeName;
  final String categoryName;
  final String categoryGroupCode;
  final String categoryGroupName;
  final String phone;
  final String addressName;
  final String roadAddressName;
  final double x; // 경도
  final double y; // 위도
  final String placeUrl;
  final int distance;

  SubwayStation({
    required this.id,
    required this.placeName,
    required this.categoryName,
    required this.categoryGroupCode,
    required this.categoryGroupName,
    required this.phone,
    required this.addressName,
    required this.roadAddressName,
    required this.x,
    required this.y,
    required this.placeUrl,
    required this.distance,
  });

  factory SubwayStation.fromJson(Map<String, dynamic> json) {
    return SubwayStation(
      id: json['id'] ?? '',
      placeName: json['place_name'] ?? '',
      categoryName: json['category_name'] ?? '',
      categoryGroupCode: json['category_group_code'] ?? '',
      categoryGroupName: json['category_group_name'] ?? '',
      phone: json['phone'] ?? '',
      addressName: json['address_name'] ?? '',
      roadAddressName: json['road_address_name'] ?? '',
      x: double.tryParse(json['x'] ?? '0') ?? 0.0,
      y: double.tryParse(json['y'] ?? '0') ?? 0.0,
      placeUrl: json['place_url'] ?? '',
      distance: int.tryParse(json['distance'] ?? '0') ?? 0,
    );
  }

  // 지하철역 이름에서 '역' 제거 (API 호출용)
  String get stationNameForApi {
    String name = placeName;
    
    // "디지털미디어시티역 공항철도" -> "디지털미디어시티"
    // "여의도역 9호선" -> "여의도"
    // "강남역" -> "강남"
    // "서울역 1호선" -> "서울"
    
    // 역명 뒤의 호선 정보 제거 (숫자호선 + 공항철도, 경의중앙선 등)
    final linePatterns = [
      RegExp(r'\s*\d+호선$'),           // "9호선" 
      RegExp(r'\s*공항철도$'),          // "공항철도"
      RegExp(r'\s*경의중앙선$'),        // "경의중앙선"
      RegExp(r'\s*수인분당선$'),        // "수인분당선"
      RegExp(r'\s*신분당선$'),          // "신분당선"
      RegExp(r'\s*경춘선$'),           // "경춘선"
      RegExp(r'\s*우이신설선$'),        // "우이신설선"
      RegExp(r'\s*서해선$'),           // "서해선"
      RegExp(r'\s*중앙선$'),           // "중앙선"
      RegExp(r'\s*경강선$'),           // "경강선"
      RegExp(r'\s*GTX-[A-Z]$'),        // "GTX-A"
    ];
    
    // 모든 호선 패턴 제거
    for (final pattern in linePatterns) {
      name = name.replaceAll(pattern, '');
    }
    
    // "역" 제거
    name = name.replaceAll('역', '');
    
    // "지하철" 제거
    name = name.replaceAll('지하철', '');
    
    // 기타 불필요한 문자 제거
    name = name.replaceAll(RegExp(r'\s*(입구|출구|출입구)\s*'), '');
    
    return name.trim();
  }

  // 거리 텍스트 표시용
  String get distanceText {
    if (distance < 1000) {
      return '${distance}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  @override
  String toString() {
    return 'SubwayStation(name: $placeName, distance: ${distanceText}, address: $addressName)';
  }
}