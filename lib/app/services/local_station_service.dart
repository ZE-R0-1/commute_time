import 'dart:math';

class LocalStationService {
  // 가장 가까운 지하철역 찾기 (API 호출 없이 로컬 계산)
  static String? findNearestStation(double latitude, double longitude) {
    try {
      print('📍 로컬 데이터로 가장 가까운 지하철역 검색 시작');
      
      // 서울 지하철역 좌표 데이터
      final stations = _getSubwayStations();
      
      double minDistance = double.infinity;
      String? nearestStation;
      
      for (final station in stations) {
        final distance = _calculateDistance(
          latitude, longitude, 
          station['latitude'], station['longitude']
        );
        
        if (distance < minDistance) {
          minDistance = distance;
          nearestStation = station['name'];
        }
      }
      
      // 최대 2km 이내의 역만 반환
      if (minDistance <= 2.0) {
        print('✅ 가장 가까운 지하철역: $nearestStation (${minDistance.toStringAsFixed(1)}km)');
        return nearestStation;
      } else {
        print('❌ 2km 반경 내에 지하철역이 없습니다 (가장 가까운 역: $nearestStation, ${minDistance.toStringAsFixed(1)}km)');
        return null;
      }
    } catch (e) {
      print('❌ 지하철역 검색 오류: $e');
      return null;
    }
  }

  // 두 좌표 간 거리 계산 (Haversine 공식)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 지구 반지름 (km)
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // 서울 지하철역 좌표 데이터 (확장된 버전)
  static List<Map<String, dynamic>> _getSubwayStations() {
    return [
      // 1호선
      {'name': '서울', 'latitude': 37.5546, 'longitude': 126.9707},
      {'name': '종각', 'latitude': 37.5703, 'longitude': 126.9826},
      {'name': '종로3가', 'latitude': 37.5717, 'longitude': 126.9915},
      {'name': '동대문', 'latitude': 37.5714, 'longitude': 127.0092},
      {'name': '청량리', 'latitude': 37.5801, 'longitude': 127.0259},
      
      // 2호선
      {'name': '강남', 'latitude': 37.4979, 'longitude': 127.0276},
      {'name': '역삼', 'latitude': 37.5000, 'longitude': 127.0359},
      {'name': '선릉', 'latitude': 37.5048, 'longitude': 127.0493},
      {'name': '삼성', 'latitude': 37.5089, 'longitude': 127.0634},
      {'name': '잠실', 'latitude': 37.5133, 'longitude': 127.1000},
      {'name': '홍대입구', 'latitude': 37.5572, 'longitude': 126.9240},
      {'name': '신촌', 'latitude': 37.5556, 'longitude': 126.9368},
      {'name': '이대', 'latitude': 37.5563, 'longitude': 126.9465},
      
      // 5호선 & 9호선
      {'name': '여의도', 'latitude': 37.5215, 'longitude': 126.9244},
      {'name': '마포', 'latitude': 37.5447, 'longitude': 126.9486},
      {'name': '공덕', 'latitude': 37.5443, 'longitude': 126.9514},
      
      // 더 많은 역들... (필요에 따라 확장)
    ];
  }
}