import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../entities/subway_station_entity.dart';
import '../entities/subway_arrival_entity.dart';

/// 지하철 검색 Repository 인터페이스
abstract class SubwayRepository {
  /// 근처 지하철역 검색
  Future<List<SubwayStationEntity>> searchNearbyStations(LatLng center);

  /// 지하철 도착정보 조회
  Future<List<SubwayArrivalEntity>> getArrivalInfo(String stationName);
}