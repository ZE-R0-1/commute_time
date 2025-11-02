import '../entities/seoul_bus_arrival_entity.dart';

/// 서울 버스 도착정보 Repository 인터페이스
abstract class SeoulBusArrivalRepository {
  /// 정류소별 버스 도착정보 조회
  Future<List<SeoulBusArrivalEntity>> getBusArrivalInfo(String stationId);

  /// 도시코드와 정류소ID로 버스 도착정보 조회
  Future<List<SeoulBusArrivalEntity>> getBusArrivalInfoWithCityCode(
    String cityCode,
    String nodeId,
  );
}
