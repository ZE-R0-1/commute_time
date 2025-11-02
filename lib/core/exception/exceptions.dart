// 기본 예외 클래스
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

// 네트워크 예외
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
  }) : super(message: message, code: code ?? 'network_error');
}

// 서버 예외 (4xx, 5xx)
class ServerException extends AppException {
  final int statusCode;

  ServerException({
    required String message,
    required this.statusCode,
    String? code,
  }) : super(message: message, code: code ?? 'server_error');
}

// 파싱 예외
class ParsingException extends AppException {
  ParsingException({
    required String message,
    String? code,
  }) : super(message: message, code: code ?? 'parsing_error');
}

// 캐시 예외
class CacheException extends AppException {
  CacheException({
    required String message,
    String? code,
  }) : super(message: message, code: code ?? 'cache_error');
}

// 일반 예외
class GeneralException extends AppException {
  GeneralException({
    required String message,
    String? code,
  }) : super(message: message, code: code ?? 'general_error');
}
