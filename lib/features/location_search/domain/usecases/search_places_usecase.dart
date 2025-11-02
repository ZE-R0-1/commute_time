import '../entities/address_entity.dart';
import '../repositories/map_repository.dart';

/// 장소 검색 UseCase
class SearchPlacesUseCase {
  final MapRepository repository;

  SearchPlacesUseCase({required this.repository});

  Future<List<AddressEntity>> call(String query) {
    return repository.searchPlaces(query);
  }
}