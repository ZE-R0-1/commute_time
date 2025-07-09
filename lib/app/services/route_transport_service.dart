import 'dart:async';
import '../models/route_models.dart';
import 'route_service.dart';
import 'subway_service.dart';
import 'bus_service_simple.dart';

/// 경로 기반 실시간 교통정보 통합 서비스
/// 출퇴근 경로상의 모든 지하철역과 버스정류장의 실시간 정보를 제공
class RouteTransportService {
  
  /// 경로 기반 실시간 교통정보 조회
  static Future<RouteBasedTransportInfo?> getRouteBasedTransportInfo({
    required double homeLat,
    required double homeLng,
    required String homeAddress,
    required double workLat,
    required double workLng,
    required String workAddress,
    required CommuteDirection direction,
  }) async {
    try {
      print('=== 경로 기반 교통정보 조회 ===');
      print('방향: ${direction.name}');
      
      // 1. 출퇴근 경로 조회
      CommuteRoute? route;
      if (direction == CommuteDirection.toWork) {
        // 집 → 회사
        route = await RouteService.getCommuteRoute(
          startLat: homeLat,
          startLng: homeLng,
          endLat: workLat,
          endLng: workLng,
          startName: homeAddress,
          endName: workAddress,
        );
      } else if (direction == CommuteDirection.toHome) {
        // 회사 → 집
        route = await RouteService.getCommuteRoute(
          startLat: workLat,
          startLng: workLng,
          endLat: homeLat,
          endLng: homeLng,
          startName: workAddress,
          endName: homeAddress,
        );
      } else {
        // 유연 모드 - 기본적으로 집 → 회사
        route = await RouteService.getCommuteRoute(
          startLat: homeLat,
          startLng: homeLng,
          endLat: workLat,
          endLng: workLng,
          startName: homeAddress,
          endName: workAddress,
        );
      }
      
      if (route == null) {
        print('경로 조회 실패');
        return null;
      }
      
      print('경로 조회 성공: ${route.routeSummary}');
      print('총 소요시간: ${route.totalDurationText}');
      
      // 2. 경로상 지하철역 실시간 정보 조회
      final subwayInfos = await _getSubwayInfosFromRoute(route);
      
      // 3. 경로상 버스정류장 실시간 정보 조회
      final busInfos = await _getBusInfosFromRoute(route);
      
      return RouteBasedTransportInfo(
        route: route,
        subwayInfos: subwayInfos,
        busInfos: busInfos,
        lastUpdated: DateTime.now(),
      );
      
    } catch (e) {
      print('경로 기반 교통정보 조회 오류: $e');
      return null;
    }
  }

  /// 경로상 지하철역 실시간 정보 조회
  static Future<List<SubwayStationInfo>> _getSubwayInfosFromRoute(CommuteRoute route) async {
    final subwayInfos = <SubwayStationInfo>[];
    
    try {
      print('=== 경로상 지하철역 실시간 정보 조회 ===');
      
      for (final section in route.subwaySections) {
        print('지하철 구간: ${section.startStationName} → ${section.endStationName} (${section.lineName})');
        
        // 시작역 정보
        if (section.startStationName.isNotEmpty) {
          try {
            final arrivals = await SubwayService.getRealtimeArrival(section.startStationName);
            
            // 해당 노선만 필터링
            final filteredArrivals = arrivals.where((arrival) {
              return arrival.lineDisplayName == section.lineName ||
                     arrival.lineDisplayName.contains(_extractLineNumber(section.lineName));
            }).toList();
            
            if (filteredArrivals.isNotEmpty) {
              subwayInfos.add(SubwayStationInfo(
                stationName: section.startStationName,
                lineName: section.lineName,
                color: section.color,
                arrivals: filteredArrivals,
              ));
              print('${section.startStationName} 실시간 정보: ${filteredArrivals.length}개');
            }
          } catch (e) {
            print('${section.startStationName} 정보 조회 오류: $e');
          }
        }
        
        // 도착역 정보 (환승역인 경우)
        if (section.endStationName.isNotEmpty && section.endStationName != section.startStationName) {
          try {
            final arrivals = await SubwayService.getRealtimeArrival(section.endStationName);
            
            // 해당 노선만 필터링
            final filteredArrivals = arrivals.where((arrival) {
              return arrival.lineDisplayName == section.lineName ||
                     arrival.lineDisplayName.contains(_extractLineNumber(section.lineName));
            }).toList();
            
            if (filteredArrivals.isNotEmpty) {
              subwayInfos.add(SubwayStationInfo(
                stationName: section.endStationName,
                lineName: section.lineName,
                color: section.color,
                arrivals: filteredArrivals,
              ));
              print('${section.endStationName} 실시간 정보: ${filteredArrivals.length}개');
            }
          } catch (e) {
            print('${section.endStationName} 정보 조회 오류: $e');
          }
        }
      }
      
      print('지하철 실시간 정보 조회 완료: ${subwayInfos.length}개 역');
      
    } catch (e) {
      print('지하철 실시간 정보 조회 전체 오류: $e');
    }
    
    return subwayInfos;
  }

  /// 경로상 버스정류장 실시간 정보 조회
  static Future<List<BusStationInfo>> _getBusInfosFromRoute(CommuteRoute route) async {
    final busInfos = <BusStationInfo>[];
    
    try {
      print('=== 경로상 버스정류장 실시간 정보 조회 ===');
      
      for (final section in route.busSections) {
        print('버스 구간: ${section.startStationName} → ${section.endStationName} (${section.lineName})');
        
        // 시작 정류장 정보
        if (section.startStationName.isNotEmpty) {
          try {
            print('버스 정류장 정보 조회: ${section.startStationName}');
            
            // 정류장명으로 정류장 정보 찾기 (좌표 + ID)
            final busStation = await SimpleBusService.findStationByName(section.startStationName);
            
            if (busStation != null) {
              // 🆕 향상된 실시간 정보 조회 (경유 버스 정보 + 실시간 도착 정보 결합)
              final enhancedArrivals = await SimpleBusService.getEnhancedRealtimeInfo(busStation.stationId);
              
              // 해당 노선만 필터링
              final filteredArrivals = enhancedArrivals.where((arrival) {
                return arrival.routeName == section.lineName ||
                       arrival.routeName.contains(_extractBusNumber(section.lineName));
              }).toList();
              
              // 필터링된 결과가 없으면 전체 정보 표시 (경로상 정류장이므로)
              final finalArrivals = filteredArrivals.isNotEmpty ? filteredArrivals : enhancedArrivals.take(3).toList();
              
              if (finalArrivals.isNotEmpty) {
                busInfos.add(BusStationInfo(
                  stationName: section.startStationName,
                  stationId: busStation.stationId,
                  arrivals: finalArrivals,
                ));
                print('${section.startStationName} 향상된 버스 실시간 정보: ${finalArrivals.length}개 (필터: ${filteredArrivals.length}개)');
              }
            } else {
              print('${section.startStationName} 버스 정류장 정보를 찾을 수 없음');
            }
          } catch (e) {
            print('${section.startStationName} 버스 정보 조회 오류: $e');
          }
        }
      }
      
      print('버스 실시간 정보 조회 완료: ${busInfos.length}개 정류장');
      
    } catch (e) {
      print('버스 실시간 정보 조회 전체 오류: $e');
    }
    
    return busInfos;
  }

  /// 노선명에서 숫자 추출 (예: "2호선" → "2")
  static String _extractLineNumber(String lineName) {
    final match = RegExp(r'(\d+)').firstMatch(lineName);
    return match?.group(1) ?? '';
  }

  /// 버스 노선명에서 번호 추출 (예: "271번" → "271")
  static String _extractBusNumber(String lineName) {
    final match = RegExp(r'(\d+)').firstMatch(lineName);
    return match?.group(1) ?? '';
  }

  /// 현재 시간 기준 출퇴근 방향 자동 판단
  static CommuteDirection getRecommendedDirection() {
    return RouteService.getCommuteDirection();
  }

  /// 경로 기반 알림 메시지 생성
  static List<String> generateRouteAlerts(RouteBasedTransportInfo info) {
    final alerts = <String>[];
    
    try {
      // 지하철 지연 알림
      for (final subwayInfo in info.subwayInfos) {
        for (final arrival in subwayInfo.arrivals) {
          if (arrival.barvlDt > 600) { // 10분 이상 지연
            alerts.add('${subwayInfo.stationName} ${subwayInfo.lineName}: 다음 열차 ${arrival.barvlDt ~/ 60}분 후 도착');
          }
        }
      }
      
      // 버스 지연 알림
      for (final busInfo in info.busInfos) {
        for (final arrival in busInfo.arrivals) {
          final arrivalMinutes = arrival.arrivalTime1 ~/ 60;
          if (arrivalMinutes > 15) { // 15분 이상 지연
            alerts.add('${busInfo.stationName} ${arrival.routeName}번: 다음 버스 ${arrivalMinutes}분 후 도착');
          }
        }
      }
      
      // 전체 경로 소요시간 알림
      alerts.add('예상 소요시간: ${info.route.totalDurationText}');
      
    } catch (e) {
      print('알림 메시지 생성 오류: $e');
    }
    
    return alerts;
  }
}