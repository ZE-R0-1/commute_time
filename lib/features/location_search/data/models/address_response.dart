import '../../domain/entities/address_entity.dart';

/// 주소 정보 API 응답 모델
class AddressResponse {
  final String place_name;
  final String address_name;
  final String road_address_name;
  final double y;
  final double x;
  final String category_name;
  final String phone;

  AddressResponse({
    required this.place_name,
    required this.address_name,
    required this.road_address_name,
    required this.y,
    required this.x,
    required this.category_name,
    required this.phone,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    final x = json['x'];
    final y = json['y'];

    double xValue = (x is double) ? x : ((x is int) ? x.toDouble() : double.parse(x.toString()));
    double yValue = (y is double) ? y : ((y is int) ? y.toDouble() : double.parse(y.toString()));

    return AddressResponse(
      place_name: json['place_name'] as String? ?? '',
      address_name: json['address_name'] as String? ?? '',
      road_address_name: json['road_address_name'] as String? ?? '',
      y: yValue,
      x: xValue,
      category_name: json['category_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'place_name': place_name,
    'address_name': address_name,
    'road_address_name': road_address_name,
    'y': y,
    'x': x,
    'category_name': category_name,
    'phone': phone,
  };

  /// 도메인 엔티티로 변환
  AddressEntity toEntity() {
    return AddressEntity(
      placeName: place_name,
      addressName: address_name,
      roadAddressName: road_address_name,
      latitude: y,
      longitude: x,
      categoryName: category_name,
      phone: phone,
    );
  }
}