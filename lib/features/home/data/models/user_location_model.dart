import '../../domain/entities/user_location_entity.dart';

/// 사용자 위치 정보 모델
class UserLocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final double accuracy;
  final DateTime timestamp;

  UserLocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.accuracy,
    required this.timestamp,
  });

  /// 엔티티로 변환
  UserLocationEntity toEntity() {
    return UserLocationEntity(
      latitude: latitude,
      longitude: longitude,
      address: address,
      accuracy: accuracy,
      timestamp: timestamp,
    );
  }
}