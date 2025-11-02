import 'package:equatable/equatable.dart';

/// 위치 권한 결과 엔티티
class LocationPermissionEntity extends Equatable {
  final bool success;
  final String message;
  final LocationErrorType? errorType;

  const LocationPermissionEntity({
    required this.success,
    required this.message,
    this.errorType,
  });

  @override
  List<Object?> get props => [success, message, errorType];
}

/// 오류 타입
enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}