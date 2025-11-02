import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../entities/place_entity.dart';
import '../repositories/map_repository.dart';

/// 근처 장소 검색 UseCase
class SearchNearbyPlacesUseCase {
  final MapRepository repository;

  SearchNearbyPlacesUseCase({required this.repository});

  Future<List<PlaceEntity>> call({
    required LatLng center,
    required String categoryCode,
    int radius = 1000,
    int size = 15,
  }) {
    return repository.searchNearbyPlaces(
      center: center,
      categoryCode: categoryCode,
      radius: radius,
      size: size,
    );
  }
}
