/// API 호출 관련 예외 정의
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalException;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}

/// 네트워크 연결 실패
class NetworkException extends ApiException {
  NetworkException({
    String message = '네트워크 연결을 확인해주세요',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// 서버 오류 (5xx)
class ServerException extends ApiException {
  ServerException({
    required String message,
    required int statusCode,
    dynamic originalException,
  }) : super(
    message: message,
    statusCode: statusCode,
    originalException: originalException,
  );
}

/// 클라이언트 오류 (4xx)
class ClientException extends ApiException {
  ClientException({
    required String message,
    required int statusCode,
    dynamic originalException,
  }) : super(
    message: message,
    statusCode: statusCode,
    originalException: originalException,
  );
}

/// 인증 오류 (401)
class UnauthorizedException extends ClientException {
  UnauthorizedException({
    String message = '인증이 필요합니다',
    dynamic originalException,
  }) : super(
    message: message,
    statusCode: 401,
    originalException: originalException,
  );
}

/// 요청 오류 (400)
class BadRequestException extends ClientException {
  BadRequestException({
    required String message,
    dynamic originalException,
  }) : super(
    message: message,
    statusCode: 400,
    originalException: originalException,
  );
}

/// 찾을 수 없음 (404)
class NotFoundException extends ClientException {
  NotFoundException({
    String message = '요청한 리소스를 찾을 수 없습니다',
    dynamic originalException,
  }) : super(
    message: message,
    statusCode: 404,
    originalException: originalException,
  );
}

/// 타임아웃
class TimeoutException extends ApiException {
  TimeoutException({
    String message = '요청 시간이 초과되었습니다',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// 파싱 오류
class ParsingException extends ApiException {
  ParsingException({
    required String message,
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}