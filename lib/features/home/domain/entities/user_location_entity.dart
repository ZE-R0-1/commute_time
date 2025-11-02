import 'package:equatable/equatable.dart';

/// 사용자 위치 정보 엔티티
class UserLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String address;
  final double accuracy;
  final DateTime timestamp;

  const UserLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.accuracy,
    required this.timestamp,
  });

  /// 도착 정확도 상태
  LocationAccuracyStatus get accuracyStatus {
    if (accuracy <= 10) return LocationAccuracyStatus.excellent;
    if (accuracy <= 50) return LocationAccuracyStatus.good;
    if (accuracy <= 100) return LocationAccuracyStatus.fair;
    return LocationAccuracyStatus.poor;
  }

  /// 위치 정확도 텍스트
  String get accuracyText {
    switch (accuracyStatus) {
      case LocationAccuracyStatus.excellent:
        return '매우 정확 (±${accuracy.round()}m)';
      case LocationAccuracyStatus.good:
        return '정확 (±${accuracy.round()}m)';
      case LocationAccuracyStatus.fair:
        return '보통 (±${accuracy.round()}m)';
      case LocationAccuracyStatus.poor:
        return '부정확 (±${accuracy.round()}m)';
    }
  }

  @override
  List<Object?> get props => [latitude, longitude, address, accuracy, timestamp];
}

/// 위치 정확도 상태
enum LocationAccuracyStatus {
  excellent, // 10m 이하
  good,      // 50m 이하
  fair,      // 100m 이하
  poor,      // 100m 초과
}