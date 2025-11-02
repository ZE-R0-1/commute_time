import '../entities/bus_arrival_info_entity.dart';
import '../repositories/bus_arrival_repository.dart';

/// 특정 노선의 버스 도착정보 조회 UseCase
class GetBusArrivalItemUseCase {
  final BusArrivalRepository repository;

  GetBusArrivalItemUseCase({required this.repository});

  Future<BusArrivalInfoEntity?> call(String stationId, String routeId, int staOrder) {
    return repository.getBusArrivalItemv2(stationId, routeId, staOrder);
  }
}