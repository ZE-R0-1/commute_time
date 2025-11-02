import '../../domain/entities/address_result_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';

/// 주소 검색 Repository 구현체
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;

  AddressRepositoryImpl({
    required AddressRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<AddressResultEntity>> searchAddress(String query) async {
    final results = await _remoteDataSource.searchAddress(query);
    return results.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<AddressResultEntity>> searchByKeyword(String query) async {
    final results = await _remoteDataSource.searchByKeyword(query);
    return results.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<AddressResultEntity>> searchByAddress(String query) async {
    final results = await _remoteDataSource.searchByAddress(query);
    return results.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> testApiConnection() {
    return _remoteDataSource.testApiConnection();
  }
}