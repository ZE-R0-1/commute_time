import '../entities/bus_arrival_info_entity.dart';

/// 버스 도착정보 Repository 인터페이스
abstract class BusArrivalRepository {
  /// 정류소별 버스 도착정보 조회
  Future<List<BusArrivalInfoEntity>> getBusArrivalInfo(String stationId);

  /// 특정 노선의 정류소별 버스 도착정보 조회 (routeId, staOrder 사용)
  Future<BusArrivalInfoEntity?> getBusArrivalItemv2(String stationId, String routeId, int staOrder);
}