import '../../domain/entities/address_result_entity.dart';

/// 주소 검색 결과 데이터 모델
class AddressResultModel {
  final String placeName;
  final String fullAddress;
  final String roadAddress;
  final String jibunAddress;
  final double? latitude;
  final double? longitude;
  final String category;

  AddressResultModel({
    required this.placeName,
    required this.fullAddress,
    required this.roadAddress,
    required this.jibunAddress,
    this.latitude,
    this.longitude,
    this.category = '',
  });

  /// 키워드 검색 결과에서 생성
  factory AddressResultModel.fromKeywordJson(Map<String, dynamic> json) {
    final placeName = json['place_name'] ?? '';
    final roadAddress = json['road_address_name'] ?? '';
    final jibunAddress = json['address_name'] ?? '';
    final category = json['category_name'] ?? '';

    // 전체 주소 결정 (도로명 주소 우선, 없으면 지번 주소)
    final fullAddress = roadAddress.isNotEmpty ? roadAddress : jibunAddress;

    return AddressResultModel(
      placeName: placeName,
      fullAddress: fullAddress,
      roadAddress: roadAddress,
      jibunAddress: jibunAddress,
      latitude: double.tryParse(json['y'] ?? ''),
      longitude: double.tryParse(json['x'] ?? ''),
      category: category,
    );
  }

  /// 주소 검색 결과에서 생성
  factory AddressResultModel.fromAddressJson(Map<String, dynamic> json) {
    final roadAddress = json['road_address']?['address_name'] ?? '';
    final jibunAddress = json['address']?['address_name'] ?? '';

    // 전체 주소 결정
    final fullAddress = roadAddress.isNotEmpty ? roadAddress : jibunAddress;

    return AddressResultModel(
      placeName: '', // 주소 검색에서는 장소명 없음
      fullAddress: fullAddress,
      roadAddress: roadAddress,
      jibunAddress: jibunAddress,
      latitude: double.tryParse(json['y'] ?? ''),
      longitude: double.tryParse(json['x'] ?? ''),
    );
  }

  /// 엔티티로 변환
  AddressResultEntity toEntity() {
    return AddressResultEntity(
      placeName: placeName,
      fullAddress: fullAddress,
      roadAddress: roadAddress,
      jibunAddress: jibunAddress,
      latitude: latitude,
      longitude: longitude,
      category: category,
    );
  }
}