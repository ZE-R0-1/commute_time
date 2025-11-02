import '../../domain/entities/location_permission_entity.dart';

/// 위치 권한 결과 모델
class LocationPermissionModel {
  final bool success;
  final String message;
  final LocationErrorType? errorType;

  LocationPermissionModel({
    required this.success,
    required this.message,
    this.errorType,
  });

  /// 엔티티로 변환
  LocationPermissionEntity toEntity() {
    return LocationPermissionEntity(
      success: success,
      message: message,
      errorType: errorType,
    );
  }
}