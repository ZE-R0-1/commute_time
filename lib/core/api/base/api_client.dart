import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../exceptions/api_exceptions.dart';

/// 기본 API 클라이언트
/// 모든 API 클라이언트는 이 클래스를 상속받아 구현합니다.
abstract class BaseApiClient {
  final http.Client httpClient;

  BaseApiClient({required this.httpClient});

  /// GET 요청
  Future<Map<String, dynamic>> get({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse(url);
      final queryUri = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await httpClient
          .get(
            queryUri,
            headers: _buildHeaders(headers),
          )
          .timeout(
            ApiConstants.connectTimeout,
            onTimeout: () => throw TimeoutException(),
          );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(originalException: e);
    }
  }

  /// POST 요청
  Future<Map<String, dynamic>> post({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) async {
    try {
      final uri = Uri.parse(url);
      final queryUri = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await httpClient
          .post(
            queryUri,
            headers: _buildHeaders(headers),
            body: body,
          )
          .timeout(
            ApiConstants.connectTimeout,
            onTimeout: () => throw TimeoutException(),
          );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(originalException: e);
    }
  }

  /// PUT 요청
  Future<Map<String, dynamic>> put({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) async {
    try {
      final uri = Uri.parse(url);
      final queryUri = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await httpClient
          .put(
            queryUri,
            headers: _buildHeaders(headers),
            body: body,
          )
          .timeout(
            ApiConstants.connectTimeout,
            onTimeout: () => throw TimeoutException(),
          );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(originalException: e);
    }
  }

  /// DELETE 요청
  Future<Map<String, dynamic>> delete({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse(url);
      final queryUri = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await httpClient
          .delete(
            queryUri,
            headers: _buildHeaders(headers),
          )
          .timeout(
            ApiConstants.connectTimeout,
            onTimeout: () => throw TimeoutException(),
          );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(originalException: e);
    }
  }

  /// HTTP 응답 처리
  Map<String, dynamic> _handleResponse(http.Response response) {
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 성공 응답
      try {
        return _parseJson(response.body);
      } catch (e) {
        throw ParsingException(
          message: '응답 파싱 오류: ${e.toString()}',
          originalException: e,
        );
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      // 클라이언트 오류
      final errorBody = _parseJson(response.body);
      final errorMessage = _extractErrorMessage(errorBody);

      if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: errorMessage,
          originalException: errorBody,
        );
      } else if (response.statusCode == 400) {
        throw BadRequestException(
          message: errorMessage,
          originalException: errorBody,
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException(
          message: errorMessage,
          originalException: errorBody,
        );
      } else {
        throw ClientException(
          message: errorMessage,
          statusCode: response.statusCode,
          originalException: errorBody,
        );
      }
    } else if (response.statusCode >= 500) {
      // 서버 오류
      final errorBody = _parseJson(response.body);
      final errorMessage = _extractErrorMessage(errorBody);

      throw ServerException(
        message: errorMessage,
        statusCode: response.statusCode,
        originalException: errorBody,
      );
    } else {
      throw ApiException(
        message: '알 수 없는 응답: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// JSON 파싱
  Map<String, dynamic> _parseJson(String body) {
    try {
      if (body.isEmpty) {
        return {};
      }
      final json = _tryParseJson(body);
      return json;
    } catch (e) {
      throw ParsingException(
        message: '응답 파싱 오류',
        originalException: e,
      );
    }
  }

  /// JSON 문자열 파싱
  Map<String, dynamic> _tryParseJson(String body) {
    try {
      if (body.isEmpty) {
        return {};
      }

      // dart:convert를 사용하여 JSON 파싱
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        // 배열 응답은 'data' 키로 감싸서 반환
        return {'data': decoded};
      } else {
        return {'data': decoded};
      }
    } catch (e) {
      throw FormatException('JSON 파싱 실패: $body', e.toString());
    }
  }

  /// 에러 메시지 추출
  String _extractErrorMessage(dynamic errorBody) {
    if (errorBody is Map) {
      // 다양한 에러 응답 형식 지원
      return errorBody['message'] ??
          errorBody['error'] ??
          errorBody['msg'] ??
          '요청 처리 중 오류가 발생했습니다';
    }
    return '요청 처리 중 오류가 발생했습니다';
  }

  /// 헤더 생성
  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': ApiConstants.contentTypeJson,
      'User-Agent': 'CommuteTimeApp/1.0',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// 응답 로깅
  void _logResponse(http.Response response) {
    print('📡 API 응답: ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('❌ 오류 본문: ${response.body.substring(0, 200)}');
    }
  }

  /// 요청 로깅
  void logRequest(String method, String url) {
    print('🌐 API 요청: $method $url');
  }
}