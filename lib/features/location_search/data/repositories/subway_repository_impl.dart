import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../../domain/entities/subway_station_entity.dart';
import '../../domain/entities/subway_arrival_entity.dart';
import '../../domain/repositories/subway_repository.dart';
import '../datasources/subway_remote_datasource.dart';

/// SubwayRepository 구현
class SubwayRepositoryImpl implements SubwayRepository {
  final SubwayRemoteDataSource remoteDataSource;

  SubwayRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SubwayStationEntity>> searchNearbyStations(LatLng center) async {
    final responses = await remoteDataSource.searchNearbyStations(center);
    return responses.map((response) => response.toEntity()).toList();
  }

  @override
  Future<List<SubwayArrivalEntity>> getArrivalInfo(String stationName) async {
    final responses = await remoteDataSource.getArrivalInfo(stationName);
    return responses.map((response) => response.toEntity()).toList();
  }
}