import 'dart:convert';
import 'package:get/get.dart';
import '../../../../core/api/services/api_provider.dart';
import '../models/address_result_model.dart';

/// 주소 검색 원격 데이터 소스 인터페이스
abstract class AddressRemoteDataSource {
  Future<List<AddressResultModel>> searchAddress(String query);
  Future<List<AddressResultModel>> searchByKeyword(String query);
  Future<List<AddressResultModel>> searchByAddress(String query);
  Future<bool> testApiConnection();
}

/// 주소 검색 원격 데이터 소스 구현
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  @override
  Future<List<AddressResultModel>> searchByKeyword(String query) async {
    if (query.isEmpty) return [];

    try {
      print('🔍 카카오 키워드 검색: $query');

      final responseData = await apiProvider.kakaoClient.searchKeyword(query: query);

      final documents = responseData['documents'] as List?;

      if (documents == null || documents.isEmpty) {
        print('📭 검색 결과가 없습니다: $query');
        return [];
      }

      print('✅ 카카오 키워드 API 성공: ${documents.length}개 결과');

      return documents.map((doc) => AddressResultModel.fromKeywordJson(doc)).toList();
    } catch (e) {
      print('💥 카카오 키워드 검색 예외: $e');
      return [];
    }
  }

  @override
  Future<List<AddressResultModel>> searchByAddress(String query) async {
    if (query.isEmpty) return [];

    try {
      print('🏠 카카오 주소 검색: $query');

      final responseData = await apiProvider.kakaoClient.searchAddress(query: query);

      final documents = responseData['documents'] as List?;

      if (documents == null || documents.isEmpty) {
        print('📭 검색 결과가 없습니다: $query');
        return [];
      }

      print('✅ 카카오 주소 API 성공: ${documents.length}개 결과');

      return documents.map((doc) => AddressResultModel.fromAddressJson(doc)).toList();
    } catch (e) {
      print('💥 카카오 주소 검색 예외: $e');
      return [];
    }
  }

  @override
  Future<List<AddressResultModel>> searchAddress(String query) async {
    if (query.isEmpty || query.length < 2) return [];

    try {
      print('🔄 통합 주소 검색 시작: $query');

      // 키워드 검색과 주소 검색을 동시에 실행
      final results = await Future.wait([
        searchByKeyword(query),
        searchByAddress(query),
      ]);

      final keywordResults = results[0];
      final addressResults = results[1];

      print('📊 키워드 검색: ${keywordResults.length}개');
      print('📊 주소 검색: ${addressResults.length}개');

      // 중복 제거 및 합치기
      final combinedResults = <AddressResultModel>[];
      final seenAddresses = <String>{};

      // 키워드 검색 결과 추가 (더 관련성 높음)
      for (final result in keywordResults) {
        if (!seenAddresses.contains(result.fullAddress)) {
          combinedResults.add(result);
          seenAddresses.add(result.fullAddress);
        }
      }

      // 주소 검색 결과 추가 (중복 제거)
      for (final result in addressResults) {
        if (!seenAddresses.contains(result.fullAddress)) {
          combinedResults.add(result);
          seenAddresses.add(result.fullAddress);
        }
      }

      final finalResults = combinedResults.take(10).toList();
      print('✅ 통합 검색 완료: ${finalResults.length}개 결과');

      // 결과 미리보기 로그
      for (int i = 0; i < finalResults.length && i < 3; i++) {
        final result = finalResults[i];
        print('  ${i + 1}. ${result.placeName.isNotEmpty ? result.placeName : result.fullAddress}');
      }

      return finalResults;

    } catch (e) {
      print('💥 카카오 통합 검색 예외: $e');
      return [];
    }
  }

  @override
  Future<bool> testApiConnection() async {
    print('🧪 카카오 API 연결 테스트 시작...');

    try {
      final results = await searchByKeyword('서울');

      if (results.isNotEmpty) {
        print('✅ 카카오 API 연결 성공!');
        return true;
      } else {
        print('⚠️ API 연결은 되지만 결과가 없습니다.');
        return false;
      }
    } catch (e) {
      print('❌ API 연결 테스트 실패: $e');
      return false;
    }
  }
}