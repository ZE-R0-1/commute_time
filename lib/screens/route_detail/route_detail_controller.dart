import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouteDetailController extends GetxController {
  // 경로 타입 ('commute' 또는 'return')
  late final String routeType;
  late final String title;
  late final String departureTime;
  late final String duration;
  late final String cost;

  // 권장 출발시간 정보
  final RxString recommendedTime = ''.obs;
  final RxString timeDescription = ''.obs;

  // 경로 단계 리스트
  final RxList<RouteStep> routeSteps = <RouteStep>[].obs;

  // 요약 정보
  final RxString totalDuration = ''.obs;
  final RxString totalCost = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // 데이터 초기화
  void _initializeData() {
    // Get.arguments에서 데이터 받기
    final arguments = Get.arguments as Map<String, dynamic>;

    routeType = arguments['type'] ?? 'commute';
    title = arguments['title'] ?? '경로 상세';
    departureTime = arguments['departureTime'] ?? '8:15';
    duration = arguments['duration'] ?? '52분';
    cost = arguments['cost'] ?? '1,370원';

    print('=== 경로 상세 데이터 초기화 ===');
    print('타입: $routeType');
    print('제목: $title');
    print('출발시간: $departureTime');

    _loadRouteData();
  }

  // 경로 데이터 로드
  void _loadRouteData() {
    // 권장 시간 정보 설정
    recommendedTime.value = departureTime;

    if (routeType == 'commute') {
      timeDescription.value = '9시 출근 기준, 여유시간 8분 포함';
      _loadCommuteRoute();
    } else {
      timeDescription.value = '18시 퇴근 기준, 여유시간 5분 포함';
      _loadReturnRoute();
    }

    // 요약 정보 설정
    totalDuration.value = duration;
    totalCost.value = cost;
  }

  // 출근 경로 로드
  void _loadCommuteRoute() {
    routeSteps.value = [
      RouteStep(
        id: 1,
        type: RouteStepType.start,
        title: '우리집',
        description: '도보 5분',
        icon: '🏠',
        color: Colors.green,
        duration: '5분',
        transport: '도보',
      ),
      RouteStep(
        id: 2,
        type: RouteStepType.subway,
        title: '2호선 역삼역',
        description: '2호선 타고 25분 (7정거장)',
        icon: '🚇',
        color: Colors.blue,
        duration: '25분',
        transport: '지하철 2호선',
        details: '역삼역 → 당산역 (7정거장)',
      ),
      RouteStep(
        id: 3,
        type: RouteStepType.transfer,
        title: '당산역 환승',
        description: '환승 시간 5분',
        icon: '🔄',
        color: Colors.orange,
        duration: '5분',
        transport: '환승',
        details: '2호선 → 9호선',
      ),
      RouteStep(
        id: 4,
        type: RouteStepType.subway,
        title: '9호선 당산역',
        description: '9호선 타고 15분 (3정거장)',
        icon: '🚇',
        color: Colors.purple,
        duration: '15분',
        transport: '지하철 9호선',
        details: '당산역 → 여의도역 (3정거장)',
      ),
      RouteStep(
        id: 5,
        type: RouteStepType.end,
        title: '회사',
        description: '도보 7분',
        icon: '🏢',
        color: Colors.red,
        duration: '7분',
        transport: '도보',
      ),
    ];
  }

  // 퇴근 경로 로드 (출근과 반대)
  void _loadReturnRoute() {
    routeSteps.value = [
      RouteStep(
        id: 1,
        type: RouteStepType.start,
        title: '회사',
        description: '도보 7분',
        icon: '🏢',
        color: Colors.red,
        duration: '7분',
        transport: '도보',
      ),
      RouteStep(
        id: 2,
        type: RouteStepType.subway,
        title: '9호선 여의도역',
        description: '9호선 타고 15분 (3정거장)',
        icon: '🚇',
        color: Colors.purple,
        duration: '15분',
        transport: '지하철 9호선',
        details: '여의도역 → 당산역 (3정거장)',
      ),
      RouteStep(
        id: 3,
        type: RouteStepType.transfer,
        title: '당산역 환승',
        description: '환승 시간 5분',
        icon: '🔄',
        color: Colors.orange,
        duration: '5분',
        transport: '환승',
        details: '9호선 → 2호선',
      ),
      RouteStep(
        id: 4,
        type: RouteStepType.subway,
        title: '2호선 당산역',
        description: '2호선 타고 25분 (7정거장)',
        icon: '🚇',
        color: Colors.blue,
        duration: '25분',
        transport: '지하철 2호선',
        details: '당산역 → 역삼역 (7정거장)',
      ),
      RouteStep(
        id: 5,
        type: RouteStepType.end,
        title: '우리집',
        description: '도보 5분',
        icon: '🏠',
        color: Colors.green,
        duration: '5분',
        transport: '도보',
      ),
    ];
  }

  // 뒤로가기
  void goBack() {
    Get.back();
  }

  // 경로 즐겨찾기 추가
  void addToFavorites() {
    Get.snackbar(
      '즐겨찾기 추가',
      '${routeType == 'commute' ? '출근' : '퇴근'} 경로가 즐겨찾기에 추가되었습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.amber,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.star, color: Colors.white),
    );

    print('${routeType == 'commute' ? '출근' : '퇴근'} 경로 즐겨찾기 추가');
  }

  // 경로 공유
  void shareRoute() {
    Get.snackbar(
      '경로 공유',
      '경로 정보를 공유할 수 있는 화면으로 이동합니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.share, color: Colors.white),
    );

    print('경로 공유 액션');
  }

  // 대안 경로 보기
  void showAlternativeRoutes() {
    Get.snackbar(
      '대안 경로',
      '다른 경로 옵션을 확인할 수 있습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.alt_route, color: Colors.white),
    );

    print('대안 경로 보기');
  }

  // 특정 단계 상세 정보
  void showStepDetail(RouteStep step) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: step.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      step.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        step.transport,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 상세 정보
            if (step.details != null) ...[
              Text(
                '상세 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step.details!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 소요시간
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.grey[600],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '소요시간: ${step.duration}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: step.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 경로 단계 타입
enum RouteStepType {
  start,    // 시작점
  subway,   // 지하철
  bus,      // 버스
  transfer, // 환승
  walk,     // 도보
  end,      // 도착점
}

// 경로 단계 모델
class RouteStep {
  final int id;
  final RouteStepType type;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final String duration;
  final String transport;
  final String? details;

  RouteStep({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.duration,
    required this.transport,
    this.details,
  });
}