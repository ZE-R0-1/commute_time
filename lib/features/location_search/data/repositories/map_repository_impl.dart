import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remoteDataSource;

  MapRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AddressEntity>> searchPlaces(String query) async {
    final responses = await remoteDataSource.searchPlaces(query);
    return responses.map((response) => response.toEntity()).toList();
  }

  @override
  Future<String?> getAddressFromCoordinate(LatLng coordinate) async {
    return await remoteDataSource.getAddressFromCoordinate(coordinate);
  }

  @override
  Future<List<PlaceEntity>> searchNearbyPlaces({
    required LatLng center,
    required String categoryCode,
    int radius = 1000,
    int size = 15,
  }) async {
    final responses = await remoteDataSource.searchNearbyPlaces(
      center: center,
      categoryCode: categoryCode,
      radius: radius,
      size: size,
    );
    return responses.map((response) => response.toEntity()).toList();
  }
}