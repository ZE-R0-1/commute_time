import 'package:equatable/equatable.dart';

/// 주소 정보 엔티티
class AddressEntity extends Equatable {
  final String placeName;
  final String addressName;
  final String roadAddressName;
  final double latitude;
  final double longitude;
  final String categoryName;
  final String phone;

  const AddressEntity({
    required this.placeName,
    required this.addressName,
    required this.roadAddressName,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.phone,
  });

  /// 표시용 주소 (도로명주소 우선)
  String get displayAddress {
    return roadAddressName.isNotEmpty ? roadAddressName : addressName;
  }

  @override
  List<Object?> get props => [
    placeName,
    addressName,
    roadAddressName,
    latitude,
    longitude,
    categoryName,
    phone,
  ];
}