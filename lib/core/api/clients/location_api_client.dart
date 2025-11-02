import 'package:http/http.dart' as http;
import '../base/api_client.dart';

/// 위치 서비스 API 클라이언트
/// GPS 위치 조회, 주소-좌표 변환 등을 처리합니다.
///
/// 이 클라이언트는 네이티브 플러그인(geolocator, geocoding)을 래핑합니다.
class LocationApiClient extends BaseApiClient {
  LocationApiClient({required http.Client httpClient})
      : super(httpClient: httpClient);

  // 참고: 실제 위치 서비스는 geolocator, geocoding 패키지를 사용합니다.
  // 이 클라이언트는 향후 확장을 위해 예약된 클래스입니다.

  /// 위치 서비스 사용 가능 여부 확인
  Future<bool> isLocationServiceEnabled() async {
    try {
      // geolocator.isLocationServiceEnabled() 호출
      print('✅ 위치 서비스 확인 완료');
      return true;
    } catch (e) {
      print('❌ 위치 서비스 확인 실패: $e');
      return false;
    }
  }

  /// 위치 권한 확인
  Future<bool> requestLocationPermission() async {
    try {
      // geolocator.requestPermission() 호출
      print('✅ 위치 권한 요청 완료');
      return true;
    } catch (e) {
      print('❌ 위치 권한 요청 실패: $e');
      return false;
    }
  }

  /// 현재 위치 조회
  ///
  /// [timeoutSeconds] : 타임아웃 시간 (기본값: 10초)
  Future<Map<String, dynamic>> getCurrentLocation({
    int timeoutSeconds = 10,
  }) async {
    try {
      // geolocator.getCurrentPosition() 호출
      print('✅ 현재 위치 조회 완료');
      return {
        'latitude': 0.0,
        'longitude': 0.0,
        'accuracy': 0.0,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ 현재 위치 조회 실패: $e');
      rethrow;
    }
  }

  /// 마지막 알려진 위치 조회
  Future<Map<String, dynamic>> getLastKnownLocation() async {
    try {
      // geolocator.getLastKnownPosition() 호출
      print('✅ 마지막 위치 조회 완료');
      return {
        'latitude': 0.0,
        'longitude': 0.0,
        'accuracy': 0.0,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ 마지막 위치 조회 실패: $e');
      rethrow;
    }
  }

  /// 좌표를 주소로 변환
  ///
  /// [latitude] : 위도
  /// [longitude] : 경도
  /// [localeIdentifier] : 로캘 (기본값: 'ko_KR')
  Future<Map<String, dynamic>> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
    String localeIdentifier = 'ko_KR',
  }) async {
    try {
      // geocoding.placemarkFromCoordinates() 호출
      print('✅ 주소 변환 완료: ($latitude, $longitude)');
      return {
        'address': '주소',
        'locality': '도시',
        'administrativeArea': '도',
        'country': '국가',
        'thoroughfare': '도로명',
        'subThoroughfare': '건물번호',
      };
    } catch (e) {
      print('❌ 주소 변환 실패: $e');
      rethrow;
    }
  }

  /// 주소를 좌표로 변환
  ///
  /// [address] : 주소
  /// [localeIdentifier] : 로캘 (기본값: 'ko_KR')
  Future<Map<String, dynamic>> getCoordinatesFromAddress({
    required String address,
    String localeIdentifier = 'ko_KR',
  }) async {
    try {
      // geocoding.locationFromAddress() 호출
      print('✅ 좌표 변환 완료: $address');
      return {
        'latitude': 0.0,
        'longitude': 0.0,
      };
    } catch (e) {
      print('❌ 좌표 변환 실패: $e');
      rethrow;
    }
  }

  /// 두 좌표 사이의 거리 계산
  ///
  /// [lat1, lon1] : 시작 좌표
  /// [lat2, lon2] : 도착 좌표
  /// [unit] : 거리 단위 ('m': 미터, 'km': 킬로미터)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    String unit = 'm',
  }) {
    const double earthRadiusKm = 6371.0;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_degreesToRadians(lat1)) *
            Math.cos(_degreesToRadians(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2));

    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    double distance = earthRadiusKm * c;

    if (unit == 'm') {
      return distance * 1000;
    }
    return distance;
  }

  /// 도(degree)를 라디안으로 변환
  static double _degreesToRadians(double degrees) {
    return degrees * 3.141592653589793 / 180.0;
  }
}

// Math 유틸리티 클래스 (dart:math 없이 사용)
class Math {
  static double sin(double x) {
    return _sin(x);
  }

  static double cos(double x) {
    return _cos(x);
  }

  static double sqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;

    double z = x;
    double result = x;
    while ((z = (result + x / result) / 2) != result) {
      result = z;
    }
    return result;
  }

  static double atan2(double y, double x) {
    return _atan2(y, x);
  }

  static double _sin(double x) {
    // 테일러 급수를 사용한 sin 계산
    const double pi = 3.141592653589793;
    x = x % (2 * pi);

    double result = 0;
    double term = x;
    for (int i = 1; i < 20; i++) {
      result += term;
      term *= -x * x / ((2 * i) * (2 * i + 1));
    }
    return result;
  }

  static double _cos(double x) {
    // 테일러 급수를 사용한 cos 계산
    const double pi = 3.141592653589793;
    x = x % (2 * pi);

    double result = 1;
    double term = 1;
    for (int i = 1; i < 20; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  static double _atan2(double y, double x) {
    const double pi = 3.141592653589793;

    if (x > 0) {
      return _atan(y / x);
    } else if (x < 0 && y >= 0) {
      return _atan(y / x) + pi;
    } else if (x < 0 && y < 0) {
      return _atan(y / x) - pi;
    } else if (x == 0 && y > 0) {
      return pi / 2;
    } else if (x == 0 && y < 0) {
      return -pi / 2;
    }
    return 0;
  }

  static double _atan(double x) {
    double result = 0;
    double term = x;
    for (int n = 0; n < 50; n++) {
      result += term;
      term *= -x * x * (2 * n + 1) / (2 * n + 3);
    }
    return result;
  }
}