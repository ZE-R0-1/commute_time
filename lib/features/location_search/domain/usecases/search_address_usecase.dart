import '../entities/address_result_entity.dart';
import '../repositories/address_repository.dart';

/// 주소 검색 UseCase
class SearchAddressUseCase {
  final AddressRepository _repository;

  SearchAddressUseCase({
    required AddressRepository repository,
  }) : _repository = repository;

  /// 통합 주소 검색 (키워드 + 주소)
  Future<List<AddressResultEntity>> call(String query) {
    return _repository.searchAddress(query);
  }

  /// 키워드로 장소 검색
  Future<List<AddressResultEntity>> searchByKeyword(String query) {
    return _repository.searchByKeyword(query);
  }

  /// 주소로 직접 검색
  Future<List<AddressResultEntity>> searchByAddress(String query) {
    return _repository.searchByAddress(query);
  }

  /// API 연결 테스트
  Future<bool> testApiConnection() {
    return _repository.testApiConnection();
  }
}