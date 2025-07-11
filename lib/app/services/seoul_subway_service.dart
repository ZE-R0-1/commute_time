import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xml/xml.dart';

class SeoulSubwayService {
  static const String _baseUrl = 'http://openapi.seoul.go.kr:8088';
  static final String _apiKey = dotenv.env['SEOUL_SUBWAY_SEARCH_API_KEY'] ?? '';
  
  /// API 키 확인
  static bool get hasValidApiKey => _apiKey.isNotEmpty;
  
  /// 지하철역 검색 (서울시 공공데이터)
  static Future<List<SeoulSubwayStation>> searchSubwayStations(String query) async {
    if (query.isEmpty) return [];
    
    // API 키 확인
    if (_apiKey.isEmpty) {
      print('❌ 서울시 지하철역 검색 API 키가 설정되지 않았습니다!');
      print('📝 .env 파일에 SEOUL_SUBWAY_SEARCH_API_KEY를 추가해주세요.');
      return [];
    }
    
    try {
      List<SeoulSubwayStation> allStations = [];
      
      // 페이지네이션으로 전체 결과 조회 (한 번에 최대 1000개)
      int startIndex = 1;
      const int pageSize = 1000;
      
      while (true) {
        final int endIndex = startIndex + pageSize - 1;
        
        // URL 구성: /API키/json/서비스명/시작위치/종료위치/역명
        // 서울시 API는 검색어 없이 전체 데이터를 가져와서 클라이언트에서 필터링하는 방식으로 변경
        final String url = '$_baseUrl/$_apiKey/json/SearchSTNBySubwayLineInfo/$startIndex/$endIndex';
        
        print('🔍 서울시 지하철역 검색 요청: $query (${startIndex}-${endIndex})');
        print('🌐 API URL: $url');
        if (startIndex == 1) {
          print('🔑 API Key: ${_apiKey.substring(0, 8)}...');
        }
        
        final response = await http.get(Uri.parse(url));
        
        print('📊 응답 상태: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          
          // 디버깅: 응답 구조만 출력 (전체 내용은 너무 길어서 생략)
          print('📝 응답 구조: ${data.keys.toList()}');
          
          // 결과 확인
          final result = data['SearchSTNBySubwayLineInfo'];
          if (result == null) {
            print('❌ 응답 데이터가 없습니다.');
            print('💡 응답 키들: ${data.keys.toList()}');
            break;
          }
          
          // 에러 체크
          final resultInfo = result['RESULT'];
          if (resultInfo != null && resultInfo['CODE'] != 'INFO-000') {
            print('❌ API 오류: ${resultInfo['CODE']} - ${resultInfo['MESSAGE']}');
            break;
          }
          
          // 총 개수 확인
          final totalCount = result['list_total_count'] ?? 0;
          print('✅ 총 검색 결과: $totalCount개');
          
          // 데이터 파싱
          final List<dynamic> rows = result['row'] ?? [];
          if (rows.isEmpty) {
            print('📄 더 이상 결과가 없습니다.');
            break;
          }
          
          print('✅ 현재 페이지 결과: ${rows.length}개');
          
          // 역 데이터 변환
          final pageStations = rows.map((row) => SeoulSubwayStation.fromJson(row)).toList();
          allStations.addAll(pageStations);
          
          // 전체 데이터를 가져왔으면 중단
          if (allStations.length >= totalCount || rows.length < pageSize) {
            break;
          }
          
          // 다음 페이지 준비
          startIndex = endIndex + 1;
          
          // API 호출 간격 (너무 빠른 연속 호출 방지)
          await Future.delayed(const Duration(milliseconds: 100));
          
        } else {
          print('❌ 지하철역 검색 실패: ${response.statusCode}');
          print('📝 응답 내용: ${response.body}');
          break;
        }
      }
      
      print('🎯 전체 검색 완료: 총 ${allStations.length}개 결과');
      
      // 검색어와 관련있는 역만 필터링하고 정렬
      final filteredAndSortedStations = _filterAndSortByRelevance(allStations, query);
      
      // 디버깅: 파싱된 역 데이터 출력
      if (filteredAndSortedStations.isNotEmpty) {
        print('🚇 파싱된 역 데이터 (필터링 및 정렬 후):');
        for (int i = 0; i < filteredAndSortedStations.length && i < 10; i++) {
          final station = filteredAndSortedStations[i];
          print('  ${i + 1}. 역명: ${station.stationName} (${station.lineNum})');
        }
      }
      
      return filteredAndSortedStations;
      
    } catch (e) {
      print('❌ 지하철역 검색 오류: $e');
      return [];
    }
  }
  
  /// 호선별 지하철역 검색
  static Future<List<SeoulSubwayStation>> searchSubwayStationsByLine(String lineNum) async {
    if (lineNum.isEmpty) return [];
    
    try {
      List<SeoulSubwayStation> allStations = [];
      
      int startIndex = 1;
      const int pageSize = 1000;
      
      while (true) {
        final int endIndex = startIndex + pageSize - 1;
        
        // URL 구성: /API키/json/서비스명/시작위치/종료위치//호선
        final String url = '$_baseUrl/$_apiKey/json/SearchSTNBySubwayLineInfo/$startIndex/$endIndex//$lineNum';
        
        print('🔍 호선별 지하철역 검색: $lineNum (${startIndex}-${endIndex})');
        
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final result = data['SearchSTNBySubwayLineInfo'];
          
          if (result == null) break;
          
          final resultInfo = result['RESULT'];
          if (resultInfo != null && resultInfo['CODE'] != 'INFO-000') {
            print('❌ API 오류: ${resultInfo['CODE']} - ${resultInfo['MESSAGE']}');
            break;
          }
          
          final List<dynamic> rows = result['row'] ?? [];
          if (rows.isEmpty) break;
          
          final pageStations = rows.map((row) => SeoulSubwayStation.fromJson(row)).toList();
          allStations.addAll(pageStations);
          
          if (rows.length < pageSize) break;
          
          startIndex = endIndex + 1;
          await Future.delayed(const Duration(milliseconds: 100));
          
        } else {
          break;
        }
      }
      
      return allStations;
      
    } catch (e) {
      print('❌ 호선별 지하철역 검색 오류: $e');
      return [];
    }
  }
  
  /// 검색어와 관련있는 역만 필터링하고 정렬
  static List<SeoulSubwayStation> _filterAndSortByRelevance(List<SeoulSubwayStation> stations, String query) {
    // 검색어를 소문자로 변환
    final lowerQuery = query.toLowerCase();
    
    // 디버깅: 처음 20개 역명 출력
    print('🔍 전체 역 데이터 샘플 (처음 20개):');
    for (int i = 0; i < stations.length && i < 20; i++) {
      final station = stations[i];
      print('  ${i + 1}. ${station.stationName} (${station.lineNum})');
    }
    
    // 검색어와 관련있는 역만 필터링
    final relevantStations = stations.where((station) {
      final lowerStationName = station.stationName.toLowerCase();
      
      // 검색어가 역명에 포함되어 있는지 확인
      final isRelevant = lowerStationName.contains(lowerQuery);
      
      // 디버깅: 관련 역 발견 시 로그 출력
      if (isRelevant) {
        print('🎯 관련 역 발견: ${station.stationName} (${station.lineNum})');
      }
      
      return isRelevant;
    }).toList();
    
    print('🔍 필터링 결과: 전체 ${stations.length}개 → 관련 ${relevantStations.length}개');
    
    // 관련있는 역이 없으면 원래 검색 결과를 그대로 반환하되 정렬은 적용
    List<SeoulSubwayStation> finalStations;
    if (relevantStations.isEmpty) {
      print('⚠️ 관련 역이 없어 전체 결과를 반환합니다.');
      finalStations = List.from(stations);
    } else {
      finalStations = relevantStations;
    }
    
    // 각 역에 대한 점수 계산 및 정렬
    finalStations.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a.stationName.toLowerCase(), lowerQuery);
      final scoreB = _calculateRelevanceScore(b.stationName.toLowerCase(), lowerQuery);
      
      return scoreB.compareTo(scoreA); // 점수가 높은 순으로 정렬
    });
    
    return finalStations;
  }
  
  /// 검색어와 역명의 일치도 점수 계산
  static int _calculateRelevanceScore(String stationName, String query) {
    int score = 0;
    
    // 1. 정확히 시작하는 경우 (가장 높은 점수)
    if (stationName.startsWith(query)) {
      score += 1000;
    }
    
    // 2. 포함하는 경우
    if (stationName.contains(query)) {
      score += 500;
    }
    
    // 3. 공통 문자 개수에 따른 점수
    int commonChars = 0;
    for (int i = 0; i < query.length && i < stationName.length; i++) {
      if (query[i] == stationName[i]) {
        commonChars++;
      }
    }
    score += commonChars * 100;
    
    // 4. 역명이 짧을수록 더 관련성이 높다고 판단
    score += (20 - stationName.length).clamp(0, 20);
    
    return score;
  }
}

/// 서울시 지하철역 데이터 모델
class SeoulSubwayStation {
  final String stationCd;        // 전철역코드
  final String stationName;      // 전철역명
  final String stationNameEng;   // 전철역명(영문)
  final String lineNum;          // 호선
  final String frCode;           // 외부코드
  final String stationNameChn;   // 전철역명(중문)
  final String stationNameJpn;   // 전철역명(일문)
  
  SeoulSubwayStation({
    required this.stationCd,
    required this.stationName,
    required this.stationNameEng,
    required this.lineNum,
    required this.frCode,
    required this.stationNameChn,
    required this.stationNameJpn,
  });
  
  factory SeoulSubwayStation.fromJson(Map<String, dynamic> json) {
    return SeoulSubwayStation(
      stationCd: json['STATION_CD'] ?? '',
      stationName: json['STATION_NM'] ?? '',
      stationNameEng: json['STATION_NM_ENG'] ?? '',
      lineNum: json['LINE_NUM'] ?? '',
      frCode: json['FR_CODE'] ?? '',
      stationNameChn: json['STATION_NM_CHN'] ?? '',
      stationNameJpn: json['STATION_NM_JPN'] ?? '',
    );
  }
  
  /// 표시용 역명 (호선 정보 포함)
  String get displayName {
    if (lineNum.isNotEmpty) {
      return '$stationName ($lineNum)';
    }
    return stationName;
  }
  
  /// 표시용 주소 (호선 정보)
  String get displayAddress {
    return lineNum.isNotEmpty ? lineNum : '정보 없음';
  }
  
  /// 거리 표시용 텍스트 (서울시 API는 거리 정보 없음)
  String get distanceText => '';
  
  @override
  String toString() {
    return 'SeoulSubwayStation(stationName: $stationName, lineNum: $lineNum)';
  }
}