import 'package:equatable/equatable.dart';

/// 장소 정보 엔티티
class PlaceEntity extends Equatable {
  final String id;
  final String placeName;
  final String addressName;
  final String roadAddressName;
  final double latitude;
  final double longitude;
  final String categoryName;
  final String phone;
  final int distance;

  const PlaceEntity({
    required this.id,
    required this.placeName,
    required this.addressName,
    required this.roadAddressName,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.phone,
    required this.distance,
  });

  /// 거리 표시 텍스트
  String get distanceText {
    if (distance < 1000) {
      return '${distance}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  @override
  List<Object?> get props => [
    id,
    placeName,
    addressName,
    roadAddressName,
    latitude,
    longitude,
    categoryName,
    phone,
    distance,
  ];
}