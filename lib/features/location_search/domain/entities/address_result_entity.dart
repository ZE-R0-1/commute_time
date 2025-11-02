import 'package:equatable/equatable.dart';

/// 주소 검색 결과 엔티티
class AddressResultEntity extends Equatable {
  final String placeName;        // 장소명 (건물명, 업체명 등)
  final String fullAddress;      // 전체 주소
  final String roadAddress;      // 도로명 주소
  final String jibunAddress;     // 지번 주소
  final double? latitude;        // 위도
  final double? longitude;       // 경도
  final String category;         // 카테고리 (업체인 경우)

  const AddressResultEntity({
    required this.placeName,
    required this.fullAddress,
    required this.roadAddress,
    required this.jibunAddress,
    this.latitude,
    this.longitude,
    this.category = '',
  });

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
  List<Object?> get props => [placeName, fullAddress, roadAddress, jibunAddress, latitude, longitude, category];
}