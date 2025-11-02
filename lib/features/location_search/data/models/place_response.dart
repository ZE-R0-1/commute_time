import '../../domain/entities/place_entity.dart';

/// 장소 정보 API 응답 모델
class PlaceResponse {
  final String id;
  final String place_name;
  final String address_name;
  final String road_address_name;
  final double y;
  final double x;
  final String category_name;
  final String phone;
  final int distance;

  PlaceResponse({
    required this.id,
    required this.place_name,
    required this.address_name,
    required this.road_address_name,
    required this.y,
    required this.x,
    required this.category_name,
    required this.phone,
    required this.distance,
  });

  factory PlaceResponse.fromJson(Map<String, dynamic> json) {
    final x = json['x'];
    final y = json['y'];
    final distance = json['distance'];

    double xValue = (x is double) ? x : ((x is int) ? x.toDouble() : double.parse(x.toString()));
    double yValue = (y is double) ? y : ((y is int) ? y.toDouble() : double.parse(y.toString()));
    int distanceValue = (distance is int) ? distance : int.parse(distance.toString());

    return PlaceResponse(
      id: json['id'] as String? ?? '',
      place_name: json['place_name'] as String? ?? '',
      address_name: json['address_name'] as String? ?? '',
      road_address_name: json['road_address_name'] as String? ?? '',
      y: yValue,
      x: xValue,
      category_name: json['category_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      distance: distanceValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'place_name': place_name,
    'address_name': address_name,
    'road_address_name': road_address_name,
    'y': y,
    'x': x,
    'category_name': category_name,
    'phone': phone,
    'distance': distance,
  };

  /// 도메인 엔티티로 변환
  PlaceEntity toEntity() {
    return PlaceEntity(
      id: id,
      placeName: place_name,
      addressName: address_name,
      roadAddressName: road_address_name,
      latitude: y,
      longitude: x,
      categoryName: category_name,
      phone: phone,
      distance: distance,
    );
  }
}