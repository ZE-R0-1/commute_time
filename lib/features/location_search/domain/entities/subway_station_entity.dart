import 'package:equatable/equatable.dart';

/// 지하철역 정보 엔티티
class SubwayStationEntity extends Equatable {
  final String id;
  final String placeName;
  final String addressName;
  final double latitude;
  final double longitude;
  final int distance;

  const SubwayStationEntity({
    required this.id,
    required this.placeName,
    required this.addressName,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  @override
  List<Object?> get props => [
    id,
    placeName,
    addressName,
    latitude,
    longitude,
    distance,
  ];

  /// 역명에서 "역" 제거
  String get cleanStationName {
    String cleaned = placeName.split(' ')[0];
    if (cleaned.endsWith('역')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }
}