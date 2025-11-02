import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../entities/bus_search_result_entity.dart';
import '../repositories/bus_repository.dart';

/// 근처 버스정류장 검색 UseCase
class SearchNearbyBusStopsUseCase {
  final BusRepository repository;

  SearchNearbyBusStopsUseCase({required this.repository});

  Future<BusSearchResultEntity> call(LatLng center) {
    return repository.searchNearbyBusStops(center);
  }
}