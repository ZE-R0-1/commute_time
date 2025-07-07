import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:math';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'kakao_local_service.dart';

class SubwayService {
  static String get _baseUrl => dotenv.env['SEOUL_SUBWAY_API_URL'] ?? 'http://swopenAPI.seoul.go.kr/api/subway';
  static String get _apiKey => dotenv.env['SEOUL_SUBWAY_API_KEY'] ?? '';
  
  static final GetStorage _storage = GetStorage();

  // 지하철 실시간 도착 정보 조회
  static Future<List<SubwayArrival>> getRealtimeArrival(String stationName) async {
    try {
      final url = '$_baseUrl/$_apiKey/json/realtimeStationArrival/0/10/$stationName';
      print('API 요청 URL: $url');
      
      final response = await http.get(Uri.parse(url));
      print('HTTP 응답 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('API 응답 본문 (첫 500자): ${responseBody.length > 500 ? responseBody.substring(0, 500) : responseBody}');
        
        final jsonData = json.decode(responseBody);
        print('파싱된 JSON 구조: ${jsonData.keys}');
        
        // RESULT 체크 (errorMessage 구조 확인)
        if (jsonData['errorMessage'] != null) {
          final resultCode = jsonData['errorMessage']['code'];
          final resultMessage = jsonData['errorMessage']['message'];
          print('API 결과 코드: $resultCode, 메시지: $resultMessage');
          
          if (resultCode != 'INFO-000') {
            throw Exception('API 오류: $resultMessage');
          }
        }
        
        // 데이터 파싱 시도 (실제 응답 구조 사용)
        List<dynamic> rows = [];
        
        // 실제 응답 구조: realtimeArrivalList
        if (jsonData['realtimeArrivalList'] != null) {
          rows = jsonData['realtimeArrivalList'];
          print('realtimeArrivalList에서 데이터 발견');
        } else {
          print('realtimeArrivalList 데이터가 null입니다');
        }
        
        print('파싱된 row 개수: ${rows.length}');
        
        return rows.map((row) => SubwayArrival.fromJson(row)).toList();
      } else {
        throw Exception('HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('지하철 실시간 정보 조회 오류: $e');
      return [];
    }
  }

  // 목적지 방향 필터링된 지하철 실시간 도착 정보 조회
  static Future<List<SubwayArrival>> getRealtimeArrivalFiltered(
    String stationName, 
    String? destinationStation
  ) async {
    try {
      // 전체 도착 정보 가져오기
      final allArrivals = await getRealtimeArrival(stationName);
      
      // 목적지가 없으면 전체 반환
      if (destinationStation == null || destinationStation.isEmpty) {
        return allArrivals;
      }
      
      print('목적지 방향 필터링: $stationName → $destinationStation');
      
      // 목적지 방향으로 향하는 지하철만 필터링
      final filteredArrivals = allArrivals.where((arrival) {
        return _isTowardsDestination(arrival, destinationStation);
      }).toList();
      
      print('필터링 결과: 전체 ${allArrivals.length}개 → 목적지 방향 ${filteredArrivals.length}개');
      
      // 필터링된 결과가 없으면 전체 반환 (안전장치)
      if (filteredArrivals.isEmpty) {
        print('목적지 방향 지하철이 없어서 전체 표시');
        return allArrivals;
      }
      
      return filteredArrivals;
    } catch (e) {
      print('목적지 방향 필터링 오류: $e');
      // 오류 발생시 일반 도착 정보라도 반환
      return await getRealtimeArrival(stationName);
    }
  }

  // 특정 방향으로 향하는지 판단
  static bool _isTowardsDestination(SubwayArrival arrival, String destinationStation) {
    final trainLine = arrival.trainLineNm.toLowerCase();
    final destination = destinationStation.toLowerCase();
    
    // 간단한 키워드 매칭으로 방향 판단
    // 예: "신림" 포함된 행선지나 방향 정보 확인
    if (destination.contains('신림')) {
      // 신림 방향 키워드들
      return trainLine.contains('신림') || 
             trainLine.contains('사당') ||  // 신림 방향 경유역
             trainLine.contains('강남') ||  // 2호선 신림 방향
             trainLine.contains('을지로') || // 2호선 내선순환
             arrival.updnLine.contains('내선') || // 2호선 내선순환
             arrival.updnLine.contains('하행'); // 일반적인 하행
    }
    
    // 기타 목적지에 대한 로직 추가 가능
    return trainLine.contains(destination);
  }

  // 주소에서 가장 가까운 지하철역 찾기 (카카오 API 사용)
  static Future<String?> findNearestStation(double latitude, double longitude) async {
    try {
      print('=== 카카오 API로 지하철역 검색 시작 ===');
      
      // 1차: 카카오 API로 실시간 지하철역 검색
      final kakaoStation = await KakaoLocalService.findNearestSubwayStation(latitude, longitude);
      
      if (kakaoStation != null) {
        final cleanedName = kakaoStation.stationNameForApi;
        print('카카오 API 검색 성공: ${kakaoStation.placeName} (${kakaoStation.distanceText})');
        print('정제된 역명: "${kakaoStation.placeName}" -> "$cleanedName"');
        return cleanedName;
      }
      
      print('카카오 API 검색 실패 - 백업 로직 사용');
      
      // 2차: 기존 하드코딩 데이터로 백업 검색
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
        print('백업 검색 성공: $nearestStation (${minDistance.toStringAsFixed(1)}km)');
        return nearestStation;
      } else {
        print('근처에 지하철역이 없습니다 (가장 가까운 역: $nearestStation, ${minDistance.toStringAsFixed(1)}km)');
        return null;
      }
    } catch (e) {
      print('지하철역 검색 오류: $e');
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

  // 서울 지하철역 좌표 데이터 (주요 역들)
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
      {'name': '아현', 'latitude': 37.5580, 'longitude': 126.9563},
      {'name': '충정로', 'latitude': 37.5600, 'longitude': 126.9633},
      {'name': '을지로입구', 'latitude': 37.5660, 'longitude': 126.9822},
      {'name': '을지로3가', 'latitude': 37.5664, 'longitude': 126.9910},
      {'name': '동대문역사문화공원', 'latitude': 37.5665, 'longitude': 127.0079},
      {'name': '신당', 'latitude': 37.5656, 'longitude': 127.0177},
      {'name': '상왕십리', 'latitude': 37.5614, 'longitude': 127.0289},
      {'name': '왕십리', 'latitude': 37.5613, 'longitude': 127.0374},
      {'name': '한양대', 'latitude': 37.5559, 'longitude': 127.0444},
      {'name': '건대입구', 'latitude': 37.5401, 'longitude': 127.0695},
      {'name': '구의', 'latitude': 37.5370, 'longitude': 127.0857},
      {'name': '강변', 'latitude': 37.5344, 'longitude': 127.0947},
      
      // 3호선
      {'name': '교대', 'latitude': 37.4924, 'longitude': 127.0141},
      {'name': '남부터미널', 'latitude': 37.4764, 'longitude': 127.0046},
      {'name': '양재', 'latitude': 37.4847, 'longitude': 127.0342},
      {'name': '매봉', 'latitude': 37.4813, 'longitude': 127.0454},
      {'name': '도곡', 'latitude': 37.4871, 'longitude': 127.0515},
      {'name': '대치', 'latitude': 37.4946, 'longitude': 127.0630},
      {'name': '학여울', 'latitude': 37.5014, 'longitude': 127.0715},
      {'name': '대청', 'latitude': 37.4984, 'longitude': 127.0765},
      {'name': '일원', 'latitude': 37.4869, 'longitude': 127.0866},
      {'name': '수서', 'latitude': 37.4873, 'longitude': 127.1006},
      {'name': '가락시장', 'latitude': 37.4932, 'longitude': 127.1184},
      {'name': '경찰병원', 'latitude': 37.4975, 'longitude': 127.1245},
      {'name': '오금', 'latitude': 37.5020, 'longitude': 127.1284},
      
      // 4호선
      {'name': '명동', 'latitude': 37.5634, 'longitude': 126.9869},
      {'name': '회현', 'latitude': 37.5587, 'longitude': 126.9784},
      {'name': '서울역', 'latitude': 37.5546, 'longitude': 126.9707},
      {'name': '숙대입구', 'latitude': 37.5447, 'longitude': 126.9297},
      {'name': '삼각지', 'latitude': 37.5344, 'longitude': 126.9734},
      {'name': '신용산', 'latitude': 37.5296, 'longitude': 126.9648},
      {'name': '이촌', 'latitude': 37.5222, 'longitude': 126.9745},
      {'name': '동작', 'latitude': 37.5082, 'longitude': 126.9789},
      {'name': '총신대입구', 'latitude': 37.5030, 'longitude': 126.9653},
      {'name': '사당', 'latitude': 37.4766, 'longitude': 126.9816},
      
      // 5호선
      {'name': '여의도', 'latitude': 37.5215, 'longitude': 126.9244},
      {'name': '마포', 'latitude': 37.5447, 'longitude': 126.9486},
      {'name': '공덕', 'latitude': 37.5443, 'longitude': 126.9514},
      {'name': '애오개', 'latitude': 37.5517, 'longitude': 126.9565},
      {'name': '충정로', 'latitude': 37.5600, 'longitude': 126.9633},
      {'name': '서대문', 'latitude': 37.5657, 'longitude': 126.9661},
      {'name': '광화문', 'latitude': 37.5720, 'longitude': 126.9763},
      {'name': '종로3가', 'latitude': 37.5717, 'longitude': 126.9915},
      {'name': '을지로4가', 'latitude': 37.5668, 'longitude': 126.9987},
      {'name': '동대문역사문화공원', 'latitude': 37.5665, 'longitude': 127.0079},
      {'name': '청구', 'latitude': 37.5606, 'longitude': 127.0179},
      {'name': '왕십리', 'latitude': 37.5613, 'longitude': 127.0374},
      {'name': '마장', 'latitude': 37.5661, 'longitude': 127.0438},
      {'name': '답십리', 'latitude': 37.5664, 'longitude': 127.0514},
      {'name': '장한평', 'latitude': 37.5612, 'longitude': 127.0646},
      {'name': '군자', 'latitude': 37.5573, 'longitude': 127.0792},
      {'name': '아차산', 'latitude': 37.5570, 'longitude': 127.0910},
      {'name': '광나루', 'latitude': 37.5450, 'longitude': 127.1085},
      {'name': '천호', 'latitude': 37.5388, 'longitude': 127.1237},
      {'name': '강동', 'latitude': 37.5269, 'longitude': 127.1262},
      {'name': '길동', 'latitude': 37.5300, 'longitude': 127.1441},
      {'name': '굽은다리', 'latitude': 37.5267, 'longitude': 127.1520},
      {'name': '명일', 'latitude': 37.5514, 'longitude': 127.1479},
      {'name': '고덕', 'latitude': 37.5553, 'longitude': 127.1546},
      {'name': '상일동', 'latitude': 37.5687, 'longitude': 127.1666},
      
      // 6호선
      {'name': '응암', 'latitude': 37.6021, 'longitude': 126.9131},
      {'name': '역촌', 'latitude': 37.5898, 'longitude': 126.9278},
      {'name': '불광', 'latitude': 37.6105, 'longitude': 126.9290},
      {'name': '연신내', 'latitude': 37.6190, 'longitude': 126.9212},
      {'name': '구산', 'latitude': 37.6101, 'longitude': 126.9169},
      {'name': '새절', 'latitude': 37.5999, 'longitude': 126.8884},
      {'name': '증산', 'latitude': 37.5885, 'longitude': 126.9062},
      {'name': '디지털미디어시티', 'latitude': 37.5767, 'longitude': 126.9006},
      {'name': '월드컵경기장', 'latitude': 37.5681, 'longitude': 126.8975},
      {'name': '마포구청', 'latitude': 37.5638, 'longitude': 126.9089},
      {'name': '망원', 'latitude': 37.5556, 'longitude': 126.9104},
      {'name': '합정', 'latitude': 37.5499, 'longitude': 126.9135},
      {'name': '상수', 'latitude': 37.5478, 'longitude': 126.9227},
      {'name': '광흥창', 'latitude': 37.5446, 'longitude': 126.9315},
      {'name': '대흥', 'latitude': 37.5456, 'longitude': 126.9590},
      {'name': '공덕', 'latitude': 37.5443, 'longitude': 126.9514},
      {'name': '효창공원앞', 'latitude': 37.5394, 'longitude': 126.9611},
      {'name': '삼각지', 'latitude': 37.5344, 'longitude': 126.9734},
      {'name': '녹사평', 'latitude': 37.5342, 'longitude': 126.9880},
      {'name': '이태원', 'latitude': 37.5344, 'longitude': 126.9945},
      {'name': '한강진', 'latitude': 37.5319, 'longitude': 127.0051},
      {'name': '버티고개', 'latitude': 37.5400, 'longitude': 127.0176},
      {'name': '약수', 'latitude': 37.5544, 'longitude': 127.0100},
      {'name': '청구', 'latitude': 37.5606, 'longitude': 127.0179},
      {'name': '신당', 'latitude': 37.5656, 'longitude': 127.0177},
      {'name': '동묘앞', 'latitude': 37.5713, 'longitude': 127.0159},
      {'name': '창신', 'latitude': 37.5742, 'longitude': 127.0180},
      {'name': '보문', 'latitude': 37.5740, 'longitude': 127.0267},
      {'name': '안암', 'latitude': 37.5859, 'longitude': 127.0297},
      {'name': '고려대', 'latitude': 37.5887, 'longitude': 127.0323},
      {'name': '월곡', 'latitude': 37.6015, 'longitude': 127.0317},
      {'name': '상월곡', 'latitude': 37.6065, 'longitude': 127.0420},
      {'name': '돌곶이', 'latitude': 37.6101, 'longitude': 127.0461},
      {'name': '석계', 'latitude': 37.6139, 'longitude': 127.0379},
      {'name': '태릉입구', 'latitude': 37.6182, 'longitude': 127.0733},
      {'name': '화랑대', 'latitude': 37.6359, 'longitude': 127.0680},
      {'name': '봉화산', 'latitude': 37.6359, 'longitude': 127.0680},
      
      // 7호선
      {'name': '건대입구', 'latitude': 37.5401, 'longitude': 127.0695},
      {'name': '뚝섬유원지', 'latitude': 37.5305, 'longitude': 127.0665},
      {'name': '청담', 'latitude': 37.5197, 'longitude': 127.0553},
      {'name': '강남구청', 'latitude': 37.5176, 'longitude': 127.0414},
      {'name': '학동', 'latitude': 37.5141, 'longitude': 127.0312},
      {'name': '논현', 'latitude': 37.5104, 'longitude': 127.0228},
      {'name': '반포', 'latitude': 37.5049, 'longitude': 127.0115},
      {'name': '고속터미널', 'latitude': 37.5041, 'longitude': 127.0048},
      {'name': '내방', 'latitude': 37.4992, 'longitude': 126.9967},
      {'name': '이수', 'latitude': 37.4857, 'longitude': 126.9818},
      {'name': '남성', 'latitude': 37.4784, 'longitude': 126.9598},
      {'name': '숭실대입구', 'latitude': 37.4967, 'longitude': 126.9576},
      {'name': '상도', 'latitude': 37.5022, 'longitude': 126.9489},
      {'name': '장승배기', 'latitude': 37.5177, 'longitude': 126.9362},
      {'name': '신대방삼거리', 'latitude': 37.4876, 'longitude': 126.9139},
      {'name': '보라매', 'latitude': 37.4938, 'longitude': 126.9248},
      {'name': '신풍', 'latitude': 37.4883, 'longitude': 126.9305},
      {'name': '대림', 'latitude': 37.4930, 'longitude': 126.8955},
      {'name': '남구로', 'latitude': 37.4764, 'longitude': 126.8873},
      {'name': '가산디지털단지', 'latitude': 37.4818, 'longitude': 126.8821},
      {'name': '철산', 'latitude': 37.4805, 'longitude': 126.8675},
      {'name': '광명사거리', 'latitude': 37.4161, 'longitude': 126.8640},
      {'name': '천왕', 'latitude': 37.4461, 'longitude': 126.8326},
      {'name': '온수', 'latitude': 37.4914, 'longitude': 126.8259},
      {'name': '까치울', 'latitude': 37.5274, 'longitude': 126.8466},
      {'name': '부천종합운동장', 'latitude': 37.5177, 'longitude': 126.8004},
      {'name': '춘의', 'latitude': 37.5337, 'longitude': 126.8229},
      {'name': '신중동', 'latitude': 37.5189, 'longitude': 126.7635},
      {'name': '부천시청', 'latitude': 37.5037, 'longitude': 126.7662},
      {'name': '상동', 'latitude': 37.4723, 'longitude': 126.7540},
      {'name': '삼산체육관', 'latitude': 37.4629, 'longitude': 126.7337},
      {'name': '굴포천', 'latitude': 37.4497, 'longitude': 126.7261},
      {'name': '부평구청', 'latitude': 37.5071, 'longitude': 126.7225},
      
      // 8호선
      {'name': '암사', 'latitude': 37.5518, 'longitude': 127.1267},
      {'name': '천호', 'latitude': 37.5388, 'longitude': 127.1237},
      {'name': '강동구청', 'latitude': 37.5300, 'longitude': 127.1236},
      {'name': '몽촌토성', 'latitude': 37.5221, 'longitude': 127.1268},
      {'name': '잠실', 'latitude': 37.5133, 'longitude': 127.1000},
      {'name': '석촌', 'latitude': 37.5053, 'longitude': 127.1058},
      {'name': '송파', 'latitude': 37.5048, 'longitude': 127.1117},
      {'name': '가락시장', 'latitude': 37.4932, 'longitude': 127.1184},
      {'name': '문정', 'latitude': 37.4848, 'longitude': 127.1222},
      {'name': '장지', 'latitude': 37.4784, 'longitude': 127.1264},
      
      // 9호선
      {'name': '개화', 'latitude': 37.5781, 'longitude': 126.7996},
      {'name': '김포공항', 'latitude': 37.5620, 'longitude': 126.8013},
      {'name': '공항시장', 'latitude': 37.5629, 'longitude': 126.8125},
      {'name': '신방화', 'latitude': 37.5581, 'longitude': 126.8130},
      {'name': '마곡나루', 'latitude': 37.5606, 'longitude': 126.8244},
      {'name': '양천향교', 'latitude': 37.5515, 'longitude': 126.8342},
      {'name': '가양', 'latitude': 37.5617, 'longitude': 126.8548},
      {'name': '증미', 'latitude': 37.5668, 'longitude': 126.8615},
      {'name': '등촌', 'latitude': 37.5507, 'longitude': 126.8659},
      {'name': '염창', 'latitude': 37.5466, 'longitude': 126.8745},
      {'name': '신목동', 'latitude': 37.5367, 'longitude': 126.8756},
      {'name': '선유도', 'latitude': 37.5347, 'longitude': 126.8936},
      {'name': '당산', 'latitude': 37.5343, 'longitude': 126.9025},
      {'name': '국회의사당', 'latitude': 37.5290, 'longitude': 126.9174},
      {'name': '여의도', 'latitude': 37.5215, 'longitude': 126.9244},
      {'name': '샛강', 'latitude': 37.5185, 'longitude': 126.9351},
      {'name': '노량진', 'latitude': 37.5136, 'longitude': 126.9426},
      {'name': '노들', 'latitude': 37.5091, 'longitude': 126.9520},
      {'name': '흑석', 'latitude': 37.5063, 'longitude': 126.9572},
      {'name': '동작', 'latitude': 37.5082, 'longitude': 126.9789},
      {'name': '구반포', 'latitude': 37.5108, 'longitude': 126.9964},
      {'name': '신반포', 'latitude': 37.5041, 'longitude': 127.0048},
      {'name': '고속터미널', 'latitude': 37.5041, 'longitude': 127.0048},
      {'name': '사평', 'latitude': 37.4919, 'longitude': 127.0100},
      {'name': '신논현', 'latitude': 37.4934, 'longitude': 127.0226},
      {'name': '언주', 'latitude': 37.4985, 'longitude': 127.0353},
      {'name': '선정릉', 'latitude': 37.5044, 'longitude': 127.0434},
      {'name': '삼성중앙', 'latitude': 37.5088, 'longitude': 127.0560},
      {'name': '종합운동장', 'latitude': 37.5112, 'longitude': 127.0730},
      {'name': '삼전', 'latitude': 37.5057, 'longitude': 127.0861},
      {'name': '석촌고분', 'latitude': 37.5053, 'longitude': 127.1058},
      {'name': '석촌', 'latitude': 37.5053, 'longitude': 127.1058},
      {'name': '송파나루', 'latitude': 37.5152, 'longitude': 127.1123},
      {'name': '한성백제', 'latitude': 37.5200, 'longitude': 127.1259},
      {'name': '올림픽공원', 'latitude': 37.5221, 'longitude': 127.1268},
      {'name': '둔촌오륜', 'latitude': 37.5271, 'longitude': 127.1361},
      {'name': '중앙보훈병원', 'latitude': 37.5555, 'longitude': 127.1457},
    ];
  }

  // 출퇴근 시간대 확인
  static bool isCommuteTime() {
    final now = DateTime.now();
    final storage = GetStorage();
    
    // 온보딩에서 설정한 출퇴근 시간 가져오기
    final startTimeStr = storage.read('work_start_time') as String?;
    final endTimeStr = storage.read('work_end_time') as String?;
    
    if (startTimeStr == null || endTimeStr == null) return false;
    
    final startTime = _parseTime(startTimeStr);
    final endTime = _parseTime(endTimeStr);
    
    if (startTime == null || endTime == null) return false;
    
    final currentTime = now.hour * 60 + now.minute;
    final workStart = startTime.hour * 60 + startTime.minute;
    final workEnd = endTime.hour * 60 + endTime.minute;
    
    // 출근 시간대 (출근 1시간 전)
    final morningStart = workStart - 60;
    final morningEnd = workStart + 30;
    
    // 퇴근 시간대 (퇴근 30분 전~1시간 후)
    final eveningStart = workEnd - 30;
    final eveningEnd = workEnd + 60;
    
    return (currentTime >= morningStart && currentTime <= morningEnd) ||
           (currentTime >= eveningStart && currentTime <= eveningEnd);
  }

  // 출근/퇴근 시간 판단
  static CommuteType getCommuteType() {
    final now = DateTime.now();
    final storage = GetStorage();
    
    final startTimeStr = storage.read('work_start_time') as String?;
    final endTimeStr = storage.read('work_end_time') as String?;
    
    if (startTimeStr == null || endTimeStr == null) return CommuteType.none;
    
    final startTime = _parseTime(startTimeStr);
    final endTime = _parseTime(endTimeStr);
    
    if (startTime == null || endTime == null) return CommuteType.none;
    
    final currentTime = now.hour * 60 + now.minute;
    final workStart = startTime.hour * 60 + startTime.minute;
    final workEnd = endTime.hour * 60 + endTime.minute;
    
    // 출근 시간대
    if (currentTime >= workStart - 60 && currentTime <= workStart + 30) {
      return CommuteType.toWork;
    }
    
    // 퇴근 시간대
    if (currentTime >= workEnd - 30 && currentTime <= workEnd + 60) {
      return CommuteType.toHome;
    }
    
    return CommuteType.none;
  }

  // 시간 문자열 파싱
  static DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }
}

// 지하철 도착 정보 모델
class SubwayArrival {
  final String subwayId;
  final String updnLine;
  final String trainLineNm;
  final String statnNm;
  final String btrainSttus;
  final int barvlDt;
  final String btrainNo;
  final String bstatnNm;
  final String arvlMsg2;
  final String arvlMsg3;
  final int arvlCd;
  final int lstcarAt;

  SubwayArrival({
    required this.subwayId,
    required this.updnLine,
    required this.trainLineNm,
    required this.statnNm,
    required this.btrainSttus,
    required this.barvlDt,
    required this.btrainNo,
    required this.bstatnNm,
    required this.arvlMsg2,
    required this.arvlMsg3,
    required this.arvlCd,
    required this.lstcarAt,
  });

  factory SubwayArrival.fromJson(Map<String, dynamic> json) {
    print('파싱 중인 JSON 데이터: ${json.keys}');
    return SubwayArrival(
      subwayId: json['subwayId'] ?? '',
      updnLine: json['updnLine'] ?? '',
      trainLineNm: json['trainLineNm'] ?? '',
      statnNm: json['statnNm'] ?? '',
      btrainSttus: json['btrainSttus'] ?? json['trainStatus'] ?? '',
      barvlDt: int.tryParse(json['barvlDt']?.toString() ?? json['leftTime']?.toString() ?? '0') ?? 0,
      btrainNo: json['btrainNo'] ?? json['trainNo'] ?? '',
      bstatnNm: json['bstatnNm'] ?? json['lastStation'] ?? '',
      arvlMsg2: json['arvlMsg2'] ?? json['arrivalTime'] ?? '',
      arvlMsg3: json['arvlMsg3'] ?? json['currentStation'] ?? '',
      arvlCd: int.tryParse(json['arvlCd']?.toString() ?? json['arrivalCode']?.toString() ?? '0') ?? 0,
      lstcarAt: int.tryParse(json['lstcarAt']?.toString() ?? json['isLastTrain']?.toString() ?? '0') ?? 0,
    );
  }

  // 지하철 호선 번호를 한글로 변환
  String get lineDisplayName {
    switch (subwayId) {
      case '1001': return '1호선';
      case '1002': return '2호선';
      case '1003': return '3호선';
      case '1004': return '4호선';
      case '1005': return '5호선';
      case '1006': return '6호선';
      case '1007': return '7호선';
      case '1008': return '8호선';
      case '1009': return '9호선';
      case '1061': return '중앙선';
      case '1063': return '경의중앙선';
      case '1065': return '공항철도';
      case '1067': return '경춘선';
      case '1075': return '수인분당선';
      case '1077': return '신분당선';
      case '1092': return '우이신설선';
      case '1093': return '서해선';
      case '1081': return '경강선';
      case '1032': return 'GTX-A';
      default: return '알 수 없음';
    }
  }

  // 도착 시간 텍스트
  String get arrivalTimeText {
    if (barvlDt == 0) {
      return arvlMsg2;
    } else {
      final minutes = (barvlDt / 60).floor();
      final seconds = barvlDt % 60;
      return '${minutes}분 ${seconds}초';
    }
  }

  // 상하행 표시
  String get directionText {
    return updnLine == '0' ? '상행' : '하행';
  }

  // 막차 여부
  bool get isLastTrain {
    return lstcarAt == 1;
  }
}

// 출퇴근 시간 타입
enum CommuteType {
  none,    // 출퇴근 시간 아님
  toWork,  // 출근 시간
  toHome   // 퇴근 시간
}