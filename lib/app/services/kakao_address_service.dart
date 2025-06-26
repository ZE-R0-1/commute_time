// lib/app/services/kakao_address_service.dart (개선된 디버깅 버전)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoAddressService {
  static final String _restApiKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
  static const String _baseUrl = 'https://dapi.kakao.com/v2/local/search';

  // 🆕 API 키 확인 메서드
  static bool get hasValidApiKey => _restApiKey.isNotEmpty;

  // 키워드로 장소 검색 (수정된 버전)
  static Future<List<AddressResult>> searchByKeyword(String query) async {
    if (query.isEmpty) return [];

    // 🆕 API 키 확인
    if (_restApiKey.isEmpty) {
      print('❌ 카카오 API 키가 설정되지 않았습니다!');
      print('📝 .env 파일에 KAKAO_REST_API_KEY를 추가해주세요.');
      return [];
    }

    try {
      // 🆕 파라미터 정리 (category_group_code 제거)
      final queryParams = <String, String>{
        'query': query,
        'size': '10',
      };

      final url = Uri.parse('$_baseUrl/keyword.json').replace(queryParameters: queryParams);

      print('🔍 카카오 키워드 검색: $query');
      print('🌐 요청 URL: $url');
      print('🔑 API 키 첫 4자리: ${_restApiKey.substring(0, 4)}****');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $_restApiKey',
          'Content-Type': 'application/json',
        },
      );

      print('📡 응답 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final documents = data['documents'] as List;

        print('✅ 카카오 키워드 API 성공: ${documents.length}개 결과');

        if (documents.isEmpty) {
          print('📭 검색 결과가 없습니다: $query');
        }

        return documents.map((doc) => AddressResult.fromKeywordJson(doc)).toList();
      } else {
        print('❌ 카카오 키워드 검색 API 오류: ${response.statusCode}');
        print('📄 응답 body: ${response.body}');

        // 🆕 일반적인 에러 케이스별 안내
        _handleApiError(response.statusCode, response.body);

        return [];
      }
    } catch (e) {
      print('💥 카카오 키워드 검색 예외: $e');
      return [];
    }
  }

  // 주소로 직접 검색 (수정된 버전)
  static Future<List<AddressResult>> searchByAddress(String query) async {
    if (query.isEmpty) return [];

    if (_restApiKey.isEmpty) {
      print('❌ 카카오 API 키가 설정되지 않았습니다!');
      return [];
    }

    try {
      final queryParams = <String, String>{
        'query': query,
        'size': '10',
      };

      final url = Uri.parse('$_baseUrl/address.json').replace(queryParameters: queryParams);

      print('🏠 카카오 주소 검색: $query');
      print('🌐 요청 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $_restApiKey',
          'Content-Type': 'application/json',
        },
      );

      print('📡 응답 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final documents = data['documents'] as List;

        print('✅ 카카오 주소 API 성공: ${documents.length}개 결과');

        return documents.map((doc) => AddressResult.fromAddressJson(doc)).toList();
      } else {
        print('❌ 카카오 주소 검색 API 오류: ${response.statusCode}');
        print('📄 응답 body: ${response.body}');

        _handleApiError(response.statusCode, response.body);

        return [];
      }
    } catch (e) {
      print('💥 카카오 주소 검색 예외: $e');
      return [];
    }
  }

  // 🆕 API 에러 처리 및 사용자 안내
  static void _handleApiError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        print('🔧 요청 파라미터를 확인해주세요.');
        if (responseBody.contains('category_group_code')) {
          print('💡 category_group_code 파라미터 문제가 해결되었는지 확인하세요.');
        }
        break;
      case 401:
        print('🔑 API 키가 잘못되었거나 없습니다.');
        print('💡 .env 파일의 KAKAO_REST_API_KEY를 확인하세요.');
        break;
      case 403:
        print('🚫 API 사용량 초과 또는 권한이 없습니다.');
        print('💡 카카오 개발자 센터에서 사용량을 확인하세요.');
        break;
      case 429:
        print('⏰ API 요청 빈도가 너무 높습니다.');
        print('💡 잠시 후 다시 시도하세요.');
        break;
      default:
        print('🌐 네트워크 오류 또는 서버 문제입니다.');
    }
  }

  // 통합 검색 (개선된 버전)
  static Future<List<AddressResult>> searchAddress(String query) async {
    if (query.isEmpty || query.length < 2) return [];

    // 🆕 API 키 체크
    if (!hasValidApiKey) {
      print('❌ 카카오 API 키가 없어서 검색을 진행할 수 없습니다.');
      return [];
    }

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
      final combinedResults = <AddressResult>[];
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

      // 🆕 결과 미리보기 로그
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

  // 🆕 API 연결 테스트 메서드
  static Future<bool> testApiConnection() async {
    print('🧪 카카오 API 연결 테스트 시작...');

    if (!hasValidApiKey) {
      print('❌ API 키가 없습니다.');
      return false;
    }

    try {
      // 간단한 검색으로 API 연결 테스트
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

// AddressResult 클래스는 기존과 동일
class AddressResult {
  final String placeName;        // 장소명 (건물명, 업체명 등)
  final String fullAddress;      // 전체 주소
  final String roadAddress;      // 도로명 주소
  final String jibunAddress;     // 지번 주소
  final double? latitude;        // 위도
  final double? longitude;       // 경도
  final String category;         // 카테고리 (업체인 경우)

  AddressResult({
    required this.placeName,
    required this.fullAddress,
    required this.roadAddress,
    required this.jibunAddress,
    this.latitude,
    this.longitude,
    this.category = '',
  });

  // 키워드 검색 결과에서 생성
  factory AddressResult.fromKeywordJson(Map<String, dynamic> json) {
    final placeName = json['place_name'] ?? '';
    final roadAddress = json['road_address_name'] ?? '';
    final jibunAddress = json['address_name'] ?? '';
    final category = json['category_name'] ?? '';

    // 전체 주소 결정 (도로명 주소 우선, 없으면 지번 주소)
    final fullAddress = roadAddress.isNotEmpty ? roadAddress : jibunAddress;

    return AddressResult(
      placeName: placeName,
      fullAddress: fullAddress,
      roadAddress: roadAddress,
      jibunAddress: jibunAddress,
      latitude: double.tryParse(json['y'] ?? ''),
      longitude: double.tryParse(json['x'] ?? ''),
      category: category,
    );
  }

  // 주소 검색 결과에서 생성
  factory AddressResult.fromAddressJson(Map<String, dynamic> json) {
    final roadAddress = json['road_address']?['address_name'] ?? '';
    final jibunAddress = json['address']?['address_name'] ?? '';

    // 전체 주소 결정
    final fullAddress = roadAddress.isNotEmpty ? roadAddress : jibunAddress;

    return AddressResult(
      placeName: '', // 주소 검색에서는 장소명 없음
      fullAddress: fullAddress,
      roadAddress: roadAddress,
      jibunAddress: jibunAddress,
      latitude: double.tryParse(json['y'] ?? ''),
      longitude: double.tryParse(json['x'] ?? ''),
    );
  }

  // 표시용 주소 (장소명이 있으면 포함)
  String get displayAddress {
    if (placeName.isNotEmpty && placeName != fullAddress) {
      return '$placeName ($fullAddress)';
    }
    return fullAddress;
  }

  // 짧은 주소 (지역명만)
  String get shortAddress {
    final parts = fullAddress.split(' ');
    if (parts.length >= 3) {
      return '${parts[0]} ${parts[1]} ${parts[2]}';
    }
    return fullAddress;
  }

  @override
  String toString() {
    return 'AddressResult(placeName: $placeName, fullAddress: $fullAddress)';
  }
}