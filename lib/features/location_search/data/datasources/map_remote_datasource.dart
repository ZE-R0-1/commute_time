import 'dart:convert';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../../../../core/api/services/api_provider.dart';
import '../models/address_response.dart';
import '../models/place_response.dart';

/// 지도 원격 데이터소스 (API 호출)
abstract class MapRemoteDataSource {
  /// 키워드로 장소 검색
  Future<List<AddressResponse>> searchPlaces(String query);

  /// 좌표로 주소 검색 (역지오코딩)
  Future<String?> getAddressFromCoordinate(LatLng coordinate);

  /// 카테고리로 주변 장소 검색
  Future<List<PlaceResponse>> searchNearbyPlaces({
    required LatLng center,
    required String categoryCode,
    int radius,
    int size,
  });
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  MapRemoteDataSourceImpl();

  @override
  Future<List<AddressResponse>> searchPlaces(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      print('🔍 장소 검색 시작: "$query"');

      final responseData = await apiProvider.kakaoClient.searchKeyword(query: query);
      final documents = responseData['documents'] as List?;

      if (documents == null || documents.isEmpty) {
        print('📭 검색 결과가 없습니다: $query');
        return [];
      }

      print('✅ 장소 검색 완료: ${documents.length}개');

      return documents.map((doc) => AddressResponse.fromJson(doc)).toList();
    } catch (e) {
      print('❌ 장소 검색 오류: $e');
      return [];
    }
  }

  @override
  Future<String?> getAddressFromCoordinate(LatLng coordinate) async {
    try {
      final responseData = await apiProvider.kakaoClient.convertCoordinateToAddress(
        x: coordinate.longitude,
        y: coordinate.latitude,
      );
      final documents = responseData['documents'] as List?;

      if (documents != null && documents.isNotEmpty) {
        final address = documents[0];
        if (address['road_address'] != null) {
          return address['road_address']['address_name'];
        } else if (address['address'] != null) {
          return address['address']['address_name'];
        }
      }
    } catch (e) {
      print('❌ 역지오코딩 오류: $e');
    }

    return null;
  }

  @override
  Future<List<PlaceResponse>> searchNearbyPlaces({
    required LatLng center,
    required String categoryCode,
    int radius = 1000,
    int size = 15,
  }) async {
    try {
      print('🏢 카테고리 검색 시작: $categoryCode');

      final responseData = await apiProvider.kakaoClient.searchCategory(
        categoryCode: categoryCode,
        x: center.longitude,
        y: center.latitude,
        radius: radius,
        size: size,
      );
      final documents = responseData['documents'] as List?;

      if (documents == null || documents.isEmpty) {
        print('📭 카테고리 검색 결과가 없습니다: $categoryCode');
        return [];
      }

      print('✅ 카테고리 검색 완료: ${documents.length}개');

      return documents.map((doc) => PlaceResponse.fromJson(doc)).toList();
    } catch (e) {
      print('❌ 카테고리 검색 오류: $e');
      return [];
    }
  }
}