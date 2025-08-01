import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class MapSearchService {
  static String get _apiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';

  // 키워드로 장소 검색
  static Future<List<AddressInfo>> searchPlaces(String query) async {
    if (_apiKey.isEmpty || query.isEmpty) {
      return [];
    }

    try {
      print('🔍 장소 검색 시작: "$query"');

      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/keyword.json'
        '?query=${Uri.encodeComponent(query)}'
        '&page=1'
        '&size=10'
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
        
        print('✅ 장소 검색 완료: ${documents.length}개');
        
        return documents.map((doc) => AddressInfo.fromJson(doc)).toList();
      } else {
        print('❌ 장소 검색 API 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ 장소 검색 오류: $e');
      return [];
    }
  }

  // 좌표로 주소 검색 (역지오코딩)
  static Future<String?> getAddressFromCoordinate(LatLng coordinate) async {
    if (_apiKey.isEmpty) {
      return null;
    }

    try {
      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/geo/coord2address.json'
        '?x=${coordinate.longitude}'
        '&y=${coordinate.latitude}'
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
        
        if (documents.isNotEmpty) {
          final address = documents[0];
          if (address['road_address'] != null) {
            return address['road_address']['address_name'];
          } else if (address['address'] != null) {
            return address['address']['address_name'];
          }
        }
      }
    } catch (e) {
      print('❌ 역지오코딩 오류: $e');
    }

    return null;
  }

  // 카테고리로 주변 장소 검색
  static Future<List<PlaceInfo>> searchNearbyPlaces({
    required LatLng center,
    required String categoryCode,
    int radius = 1000,
    int size = 15,
  }) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      print('🏢 카테고리 검색 시작: $categoryCode');

      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/category.json'
        '?category_group_code=$categoryCode'
        '&x=${center.longitude}'
        '&y=${center.latitude}'
        '&radius=$radius'
        '&sort=distance'
        '&page=1'
        '&size=$size'
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
        
        print('✅ 카테고리 검색 완료: ${documents.length}개');
        
        return documents.map((doc) => PlaceInfo.fromJson(doc)).toList();
      } else {
        print('❌ 카테고리 검색 API 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ 카테고리 검색 오류: $e');
      return [];
    }
  }

  // 지도 마커 생성 헬퍼
  static List<Marker> createMarkersFromPlaces(List<PlaceInfo> places, String prefix) {
    return places.asMap().entries.map((entry) {
      final index = entry.key;
      final place = entry.value;
      
      return Marker(
        markerId: '${prefix}_${place.id}',
        latLng: LatLng(place.latitude, place.longitude),
      );
    }).toList();
  }

  // 지도 중심점 계산
  static LatLng calculateCenter(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLng(37.5665, 126.9780); // 서울시청 기본값
    }

    if (points.length == 1) {
      return points.first;
    }

    double totalLat = 0;
    double totalLng = 0;

    for (final point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return LatLng(
      totalLat / points.length,
      totalLng / points.length,
    );
  }
}

// 주소 정보 모델
class AddressInfo {
  final String placeName;
  final String addressName;
  final String roadAddressName;
  final double latitude;
  final double longitude;
  final String categoryName;
  final String phone;

  AddressInfo({
    required this.placeName,
    required this.addressName,
    required this.roadAddressName,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.phone,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      placeName: json['place_name'] ?? '',
      addressName: json['address_name'] ?? '',
      roadAddressName: json['road_address_name'] ?? '',
      latitude: double.parse(json['y'].toString()),
      longitude: double.parse(json['x'].toString()),
      categoryName: json['category_name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  // 표시용 주소 (도로명주소 우선)
  String get displayAddress {
    return roadAddressName.isNotEmpty ? roadAddressName : addressName;
  }
}

// 장소 정보 모델
class PlaceInfo {
  final String id;
  final String placeName;
  final String addressName;
  final String roadAddressName;
  final double latitude;
  final double longitude;
  final String categoryName;
  final String phone;
  final int distance;

  PlaceInfo({
    required this.id,
    required this.placeName,
    required this.addressName,
    required this.roadAddressName,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.phone,
    required this.distance,
  });

  factory PlaceInfo.fromJson(Map<String, dynamic> json) {
    return PlaceInfo(
      id: json['id'] ?? '',
      placeName: json['place_name'] ?? '',
      addressName: json['address_name'] ?? '',
      roadAddressName: json['road_address_name'] ?? '',
      latitude: double.parse(json['y'].toString()),
      longitude: double.parse(json['x'].toString()),
      categoryName: json['category_name'] ?? '',
      phone: json['phone'] ?? '',
      distance: int.tryParse(json['distance']?.toString() ?? '0') ?? 0,
    );
  }

  // 거리 표시 텍스트
  String get distanceText {
    if (distance < 1000) {
      return '${distance}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }
}