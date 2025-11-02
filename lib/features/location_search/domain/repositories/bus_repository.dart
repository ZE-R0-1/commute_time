import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../entities/bus_search_result_entity.dart';

/// 버스 검색 Repository 인터페이스
abstract class BusRepository {
  /// 근처 버스정류장 검색 (경기도 + 서울)
  Future<BusSearchResultEntity> searchNearbyBusStops(LatLng center);
}