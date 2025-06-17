import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../services/subway_api_service.dart';
import '../../data/models/subway_arrival_model.dart';

class HomeController extends GetxController {
  final storage = GetStorage();
  final subwayApi = Get.find<SubwayApiService>();

  // 반응형 상태 변수들
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString currentTime = ''.obs;
  final RxString currentDate = ''.obs;

  // 실시간 지하철 정보
  final RxList<SubwayArrival> realtimeArrivals = <SubwayArrival>[].obs;
  final RxBool isLoadingSubway = false.obs;
  final RxString selectedStation = '강남'.obs;

  // 자주 사용하는 역들
  final RxList<Map<String, dynamic>> favoriteStations = <Map<String, dynamic>>[
    {
      'name': '강남',
      'line': '2호선',
      'lineId': '2',
      'isFavorite': true,
    },
    {
      'name': '홍대입구',
      'line': '2호선',
      'lineId': '2',
      'isFavorite': true,
    },
    {
      'name': '신촌',
      'line': '2호선',
      'lineId': '2',
      'isFavorite': false,
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _startTimeUpdate();
    _loadRealtimeSubwayInfo();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// 초기 데이터 설정
  void _initializeData() {
    _updateDateTime();

    // 다음 프레임에서 환영 메시지를 위쪽에 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        '🚇 출퇴근타임',
        '실시간 지하철 정보를 불러오는 중...',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP, // 🔝 위쪽으로 변경!
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
        margin: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w), // 반응형 여백
      );
    });
  }

  /// 실시간 지하철 정보 로드
  Future<void> _loadRealtimeSubwayInfo() async {
    try {
      isLoadingSubway.value = true;
      print('🚇 실시간 지하철 정보 로드 시작: ${selectedStation.value}');

      // 실제 API 호출
      final arrivals = await subwayApi.getRealtimeArrival(
        stationName: selectedStation.value,
      );

      realtimeArrivals.value = arrivals;

      if (arrivals.isNotEmpty) {
        print('✅ 실시간 정보 로드 완료: ${arrivals.length}개');

        // 다음 프레임에서 성공 메시지를 위쪽에 표시
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            '✅ 실시간 정보 업데이트',
            '${selectedStation.value}역 정보가 업데이트되었습니다 (${arrivals.length}개)',
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.TOP, // 🔝 위쪽으로 변경!
            backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
            colorText: Get.theme.colorScheme.primary,
            margin: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w), // 반응형 여백
          );
        });
      } else {
        print('⚠️ 도착 정보가 없습니다');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            '⚠️ 정보 없음',
            '${selectedStation.value}역의 실시간 정보가 없습니다',
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.TOP, // 🔝 위쪽으로 변경!
            margin: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w), // 반응형 여백
          );
        });
      }
    } catch (e) {
      print('❌ 실시간 정보 로드 실패: $e');

      // 에러 시 더미 데이터 표시
      realtimeArrivals.value = subwayApi.generateDummyArrivals();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          '❌ 연결 실패',
          'API 연결에 실패했습니다. 더미 데이터를 표시합니다.',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP, // 🔝 위쪽으로 변경!
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
          margin: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w), // 반응형 여백
        );
      });
    } finally {
      isLoadingSubway.value = false;
    }
  }

  /// 역 변경
  Future<void> changeStation(String stationName) async {
    if (selectedStation.value != stationName) {
      selectedStation.value = stationName;
      await _loadRealtimeSubwayInfo();
    }
  }

  /// 실시간 정보 새로고침
  Future<void> refreshSubwayInfo() async {
    await _loadRealtimeSubwayInfo();
  }

  /// 실시간 시간 업데이트만 (자동 새로고침 제거)
  void _startTimeUpdate() {
    // 🕐 매초 시간 업데이트 (시계 표시용)
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _updateDateTime();
    });

    // 🔄 1분마다 지하철 정보 자동 새로고침 → 제거!
    // 이제 사용자가 직접 새로고침 버튼을 누르거나 역을 변경할 때만 업데이트
  }

  /// 날짜/시간 업데이트
  void _updateDateTime() {
    final now = DateTime.now();
    currentTime.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    currentDate.value = '${now.month}월 ${now.day}일 ($weekday)';
  }

  /// 탭 변경
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  /// 경로 검색 (임시)
  void searchRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        '경로 검색',
        '경로 검색 기능은 다음 단계에서 구현됩니다',
        backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.secondary,
        snackPosition: SnackPosition.TOP, // 🔝 위쪽으로 변경!
        margin: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w), // 반응형 여백
      );
    });
  }

  /// 즐겨찾기 토글
  void toggleFavorite(int index) {
    if (index < favoriteStations.length) {
      favoriteStations[index]['isFavorite'] = !favoriteStations[index]['isFavorite'];
      favoriteStations.refresh();

      final station = favoriteStations[index];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          station['isFavorite'] ? '⭐ 즐겨찾기 추가' : '☆ 즐겨찾기 해제',
          '${station['name']}역 (${station['line']})',
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.TOP, // 🔝 위쪽으로 변경!
          margin: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w), // 반응형 여백
        );
      });

      // 즐겨찾기 추가 시 해당 역 정보 로드
      if (station['isFavorite']) {
        changeStation(station['name']);
      }
    }
  }

  /// 설정 화면으로 이동 (임시)
  void goToSettings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        '⚙️ 설정',
        '설정 화면은 다음 단계에서 구현됩니다',
        backgroundColor: Get.theme.colorScheme.surface,
        colorText: Get.theme.colorScheme.onSurface,
        snackPosition: SnackPosition.TOP, // 🔝 위쪽으로 변경!
        margin: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w), // 반응형 여백
      );
    });
  }

  /// 알림 확인 (임시)
  void checkNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        '🔔 알림',
        '새로운 알림이 없습니다',
        backgroundColor: Get.theme.colorScheme.surface,
        colorText: Get.theme.colorScheme.onSurface,
        snackPosition: SnackPosition.TOP, // 🔝 위쪽으로 변경!
        margin: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w), // 반응형 여백
      );
    });
  }

  /// 지하철 도착 시간 포맷팅
  String formatArrivalTime(SubwayArrival arrival) {
    if (arrival.cleanArrivalMessage.contains('곧')) {
      return '곧 도착';
    }
    return arrival.cleanArrivalMessage;
  }

  /// 노선 색상 가져오기
  String getLineColor(String lineId) {
    final colors = {
      '1': '#263C96', '2': '#00A84D', '3': '#EF7C1C', '4': '#00A4E3',
      '5': '#996CAC', '6': '#CD7C2F', '7': '#747F00', '8': '#E6186C', '9': '#BB8336',
    };
    return colors[lineId] ?? '#6B7280';
  }
}