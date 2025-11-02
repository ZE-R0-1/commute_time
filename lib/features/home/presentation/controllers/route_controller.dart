import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// 경로 관련 Controller
class RouteController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 경로 정보
  final RxString routeName = ''.obs;
  final RxString departureStation = ''.obs;
  final RxString arrivalStation = ''.obs;
  final RxList<Map<String, dynamic>> transferStations = <Map<String, dynamic>>[].obs;
  final RxBool hasRouteData = false.obs;
  final RxString activeRouteId = ''.obs;

  // 경로 데이터 로드
  void loadRouteData() {
    print('=== 경로 데이터 로딩 ===');

    final savedRoutes = _storage.read<List>('saved_routes');

    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      // 저장된 활성 경로 ID 확인
      final savedActiveRouteId = _storage.read<String>('active_route_id');

      Map<String, dynamic>? targetRoute;

      if (savedRoutes.length == 1) {
        // 경로가 1개뿐이면 자동으로 선택
        targetRoute = Map<String, dynamic>.from(savedRoutes.first as Map);
        activeRouteId.value = targetRoute['id'] ?? '';
        // 자동 선택된 경우 스토리지에도 저장
        _storage.write('active_route_id', activeRouteId.value);
      } else if (savedActiveRouteId != null && savedActiveRouteId.isNotEmpty) {
        // 저장된 활성 경로 ID가 있으면 해당 경로 찾기
        for (var route in savedRoutes) {
          final routeMap = Map<String, dynamic>.from(route as Map);
          if (routeMap['id'] == savedActiveRouteId) {
            targetRoute = routeMap;
            activeRouteId.value = savedActiveRouteId;
            break;
          }
        }

        // 저장된 활성 경로 ID에 해당하는 경로가 없으면 첫 번째 경로 사용
        if (targetRoute == null) {
          targetRoute = Map<String, dynamic>.from(savedRoutes.first as Map);
          activeRouteId.value = targetRoute['id'] ?? '';
          _storage.write('active_route_id', activeRouteId.value);
        }
      } else {
        // 활성 경로 ID가 없으면 첫 번째 경로 사용 (2개 이상일 때는 수동 선택 필요)
        targetRoute = Map<String, dynamic>.from(savedRoutes.first as Map);
        activeRouteId.value = targetRoute['id'] ?? '';
        _storage.write('active_route_id', activeRouteId.value);
      }

      if (targetRoute != null) {
        routeName.value = targetRoute['name'] ?? '저장된 경로';

        // 출발지 처리 (Map 구조만 지원)
        final departure = targetRoute['departure'];
        print('🔍 [홈화면] 출발지 원본 데이터: $departure');
        print('🔍 [홈화면] 출발지 데이터 타입: ${departure.runtimeType}');
        if (departure is Map) {
          print('🔍 [홈화면] 출발지 상세정보: name=${departure['name']}, type=${departure['type']}, lineInfo=${departure['lineInfo']}, code=${departure['code']}');
          departureStation.value = departure['name'] ?? '';
        } else {
          print('⚠️ [홈화면] 출발지가 구형식 데이터입니다. 마이그레이션이 필요합니다.');
          departureStation.value = departure?.toString() ?? '';
        }

        // 도착지 처리 (Map 구조만 지원)
        final arrival = targetRoute['arrival'];
        print('🔍 [홈화면] 도착지 원본 데이터: $arrival');
        print('🔍 [홈화면] 도착지 데이터 타입: ${arrival.runtimeType}');
        if (arrival is Map) {
          print('🔍 [홈화면] 도착지 상세정보: name=${arrival['name']}, type=${arrival['type']}, lineInfo=${arrival['lineInfo']}, code=${arrival['code']}');
          arrivalStation.value = arrival['name'] ?? '';
        } else {
          print('⚠️ [홈화면] 도착지가 구형식 데이터입니다. 마이그레이션이 필요합니다.');
          arrivalStation.value = arrival?.toString() ?? '';
        }

        final routeTransfers = targetRoute['transfers'] as List?;
        print('🔍 [홈화면] 환승지 원본 데이터: $routeTransfers');
        if (routeTransfers != null) {
          print('🔍 [홈화면] 환승지 개수: ${routeTransfers.length}');
          for (int i = 0; i < routeTransfers.length; i++) {
            final transfer = routeTransfers[i];
            print('🔍 [홈화면] 환승지 ${i+1}: $transfer');
            if (transfer is Map) {
              print('🔍 [홈화면] 환승지 ${i+1} 상세정보: name=${transfer['name']}, type=${transfer['type']}, lineInfo=${transfer['lineInfo']}, code=${transfer['code']}');
            }
          }
          transferStations.value = routeTransfers.map((transfer) =>
            Map<String, dynamic>.from(transfer as Map)).toList();
        } else {
          print('🔍 [홈화면] 환승지 없음');
          transferStations.clear();
        }

        hasRouteData.value = true;

        print('✅ 활성 경로 데이터 로드 완료:');
        print('   활성 경로 ID: ${activeRouteId.value}');
        print('   경로명: ${routeName.value}');
        print('   출발지: ${targetRoute['departure']}');
        print('   도착지: ${targetRoute['arrival']}');
        print('   환승지: ${transferStations.length}개');
        print('   총 경로 수: ${savedRoutes.length}개');
      }
    } else {
      // 온보딩 경로 확인 (Map 형식으로 저장되어 있음)
      final departureDynamic = _storage.read('onboarding_departure');
      final arrivalDynamic = _storage.read('onboarding_arrival');
      final transfers = _storage.read<List>('onboarding_transfers');

      // Map 형식의 출발지/도착지 처리
      Map<String, dynamic>? departure;
      Map<String, dynamic>? arrival;

      if (departureDynamic is Map) {
        departure = Map<String, dynamic>.from(departureDynamic);
      }

      if (arrivalDynamic is Map) {
        arrival = Map<String, dynamic>.from(arrivalDynamic);
      }

      if (departure != null && arrival != null) {
        routeName.value = '온보딩 경로';
        departureStation.value = departure['name'] ?? '';
        arrivalStation.value = arrival['name'] ?? '';

        print('🔍 [홈화면] 온보딩 출발지 원본 데이터: $departure');
        print('🔍 [홈화면] 온보딩 도착지 원본 데이터: $arrival');

        if (transfers != null) {
          print('🔍 [홈화면] 온보딩 환승지 개수: ${transfers.length}');
          transferStations.value = transfers.map((transfer) =>
            Map<String, dynamic>.from(transfer as Map)).toList();
        }

        hasRouteData.value = true;
        activeRouteId.value = 'onboarding';

        print('✅ 온보딩 경로 데이터 로드 완료:');
        print('   경로명: ${routeName.value}');
        print('   출발지: ${departure['name']} (type: ${departure['type']})');
        print('   도착지: ${arrival['name']} (type: ${arrival['type']})');
        print('   환승지: ${transferStations.length}개');
      } else {
        hasRouteData.value = false;
        activeRouteId.value = '';
        print('❌ 저장된 경로 데이터가 없습니다');
      }
    }
  }

  // 경로 데이터 새로고침
  void refreshRouteData() {
    print('🔄 홈화면 경로 데이터 새로고침 요청');
    loadRouteData();
  }

  // 경로 적용하기
  void applyRoute(String routeId) {
    print('🔄 경로 적용: $routeId');

    final savedRoutes = _storage.read<List>('saved_routes');
    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      // 해당 경로 찾기
      for (var route in savedRoutes) {
        final routeMap = Map<String, dynamic>.from(route as Map);
        if (routeMap['id'] == routeId) {
          // 활성 경로 변경
          activeRouteId.value = routeId;
          _storage.write('active_route_id', routeId);

          // 홈화면 데이터 즉시 업데이트
          routeName.value = routeMap['name'] ?? '저장된 경로';

          // 출발지 처리 (Map 구조만 지원)
          final departure = routeMap['departure'];
          if (departure is Map) {
            departureStation.value = departure['name'] ?? '';
          } else {
            print('⚠️ [경로적용] 출발지가 구형식 데이터입니다.');
            departureStation.value = departure?.toString() ?? '';
          }

          // 도착지 처리 (Map 구조만 지원)
          final arrival = routeMap['arrival'];
          if (arrival is Map) {
            arrivalStation.value = arrival['name'] ?? '';
          } else {
            print('⚠️ [경로적용] 도착지가 구형식 데이터입니다.');
            arrivalStation.value = arrival?.toString() ?? '';
          }

          final routeTransfers = routeMap['transfers'] as List?;
          if (routeTransfers != null) {
            transferStations.value = routeTransfers.map((transfer) =>
              Map<String, dynamic>.from(transfer as Map)).toList();
          } else {
            transferStations.clear();
          }

          hasRouteData.value = true;

          print('✅ 경로 적용 완료:');
          print('   활성 경로 ID: ${activeRouteId.value}');
          print('   경로명: ${routeName.value}');

          break;
        }
      }
    }
  }
}