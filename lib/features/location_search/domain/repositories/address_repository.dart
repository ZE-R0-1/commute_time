import '../entities/address_result_entity.dart';

/// 주소 검색 Repository 인터페이스
abstract class AddressRepository {
  /// 통합 주소 검색 (키워드 + 주소)
  Future<List<AddressResultEntity>> searchAddress(String query);

  /// 키워드로 장소 검색
  Future<List<AddressResultEntity>> searchByKeyword(String query);

  /// 주소로 직접 검색
  Future<List<AddressResultEntity>> searchByAddress(String query);

  /// API 연결 테스트
  Future<bool> testApiConnection();
}