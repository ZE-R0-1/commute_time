import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../entities/subway_station_entity.dart';
import '../repositories/subway_repository.dart';

/// 근처 지하철역 검색 Usecase
class SearchSubwayStationsUseCase {
  final SubwayRepository repository;

  SearchSubwayStationsUseCase({required this.repository});

  Future<List<SubwayStationEntity>> call(LatLng center) async {
    return await repository.searchNearbyStations(center);
  }
}