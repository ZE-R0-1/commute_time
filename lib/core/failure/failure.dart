import 'package:equatable/equatable.dart';

/// 기본 Failure 클래스
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// 일반 실패
class GeneralFailure extends Failure {
  GeneralFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// 네트워크 실패
class NetworkFailure extends Failure {
  NetworkFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// 서버 실패
class ServerFailure extends Failure {
  final int? statusCode;

  ServerFailure({
    required String message,
    this.statusCode,
    String? code,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [message, statusCode, code];
}

/// 파싱 실패
class ParsingFailure extends Failure {
  ParsingFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// 캐시 실패
class CacheFailure extends Failure {
  CacheFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}
