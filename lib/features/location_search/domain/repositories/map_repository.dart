import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../entities/address_entity.dart';
import '../entities/place_entity.dart';

/// 지도 검색 Repository 인터페이스
abstract class MapRepository {
  /// 키워드로 장소 검색
  Future<List<AddressEntity>> searchPlaces(String query);

  /// 좌표로 주소 검색 (역지오코딩)
  Future<String?> getAddressFromCoordinate(LatLng coordinate);

  /// 카테고리로 주변 장소 검색
  Future<List<PlaceEntity>> searchNearbyPlaces({
    required LatLng center,
    required String categoryCode,
    int radius,
    int size,
  });
}