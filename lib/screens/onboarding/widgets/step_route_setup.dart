import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../onboarding_controller.dart';

// LocationInfo 클래스 정의
class LocationInfo {
  final String name;
  final String type; // 'subway' 또는 'bus'
  final String lineInfo;
  final String code;

  LocationInfo({
    required this.name,
    required this.type,
    required this.lineInfo,
    required this.code,
  });
}

class StepRouteSetup extends GetView<OnboardingController> {
  const StepRouteSetup({super.key});

  @override
  Widget build(BuildContext context) {
    // 로컬 상태 관리
    final RxnString selectedDeparture = RxnString();
    final RxList<LocationInfo> transferStations = <LocationInfo>[].obs;
    final RxnString selectedArrival = RxnString();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // 연한 파란색
              Color(0xFFE8EAF6), // 연한 인디고색
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // 커스텀 헤더
                _buildHeader(),
                
                // 진행률 표시
                _buildProgressIndicator(),
                
                // 메인 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 출발지 설정 버튼 또는 선택된 출발지 카드
                        Obx(() {
                          if (selectedDeparture.value == null) {
                            return _buildDepartureButton(
                              onTap: () async {
                                final result = await Get.toNamed('/location-search', arguments: {
                                  'mode': 'departure',
                                  'title': '출발지 설정'
                                });
                                
                                if (result != null) {
                                  selectedDeparture.value = result['name'];
                                }
                              },
                            );
                          } else {
                            return _buildSelectedLocationCard(
                              location: LocationInfo(
                                name: selectedDeparture.value!,
                                type: 'subway',
                                lineInfo: '출발지',
                                code: '',
                              ),
                              color: const Color(0xFF3B82F6),
                              label: '출발지',
                              onDelete: () => selectedDeparture.value = null,
                            );
                          }
                        }),

                        const SizedBox(height: 16),

                        // 환승지들 표시
                        Obx(() {
                          return Column(
                            children: [
                              ...transferStations.asMap().entries.map((entry) {
                                int index = entry.key;
                                LocationInfo transfer = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildSelectedLocationCard(
                                    location: transfer,
                                    color: const Color(0xFFF97316), // 주황색
                                    label: '환승지 ${index + 1}',
                                    onDelete: () => transferStations.removeAt(index),
                                  ),
                                );
                              }),
                            ],
                          );
                        }),

                        // 환승지 추가 버튼 (주황색)
                        Obx(() {
                          if (transferStations.length < 3) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildOrangeTransferButton(
                                onTap: () async {
                                  final result = await Get.toNamed('/location-search', arguments: {
                                    'mode': 'transfer',
                                    'title': '환승지 추가'
                                  });
                                  
                                  if (result != null) {
                                    transferStations.add(LocationInfo(
                                      name: result['name'],
                                      type: result['type'] ?? 'subway',
                                      lineInfo: result['lineInfo'] ?? '',
                                      code: result['code'] ?? '',
                                    ));
                                  }
                                },
                                count: transferStations.length,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),

                        // 도착지 설정 버튼 또는 선택된 도착지 카드
                        Obx(() {
                          if (selectedArrival.value == null) {
                            return _buildArrivalButton(
                              onTap: () async {
                                final result = await Get.toNamed('/location-search', arguments: {
                                  'mode': 'arrival',
                                  'title': '도착지 설정'
                                });
                                
                                if (result != null) {
                                  selectedArrival.value = result['name'];
                                }
                              },
                            );
                          } else {
                            return _buildSelectedLocationCard(
                              location: LocationInfo(
                                name: selectedArrival.value!,
                                type: 'subway',
                                lineInfo: '도착지',
                                code: '',
                              ),
                              color: const Color(0xFF10B981),
                              label: '도착지',
                              onDelete: () => selectedArrival.value = null,
                            );
                          }
                        }),

                        const SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),

                
                // 커스텀 하단 버튼
                _buildCustomBottomBar(selectedDeparture, selectedArrival),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.previousStep(),
            child: Container(
              width: 24,
              height: 24,
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '경로 설정',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '출발지, 환승지, 도착지 설정',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '4단계 중 1단계 완료',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '25%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final gapWidth = 8.0; // 👈 여백 넓히기 (4 → 6)
        final totalGaps = gapWidth * 3; // 3개의 간격
        final segmentWidth = (totalWidth - totalGaps) / 4;

        return Row(
          children: [
            // 1단계 (완료)
            Container(
              width: segmentWidth,
              height: 6, // 👈 높이 키우기 (4 → 6)
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(3), // 👈 radius도 조정 (2 → 3)
              ),
            ),
            SizedBox(width: gapWidth), // 👈 넓어진 여백
            // 2~4단계 (미완료)
            ...List.generate(3, (index) => [
              Container(
                width: segmentWidth,
                height: 6, // 👈 높이 키우기
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3), // 👈 radius 조정
                ),
              ),
              if (index < 2) SizedBox(width: gapWidth), // 👈 넓어진 여백
            ]).expand((x) => x),
          ],
        );
      },
    );
  }


  Widget _buildSelectedLocationCard({
    required LocationInfo location,
    required Color color,
    required String label,
    required VoidCallback onDelete,
  }) {
    IconData getLocationIcon() {
      switch (location.type) {
        case 'subway':
          return Icons.train;
        case 'bus':
          return Icons.directions_bus;
        case 'map':
          return Icons.location_on;
        default:
          return Icons.location_on;
      }
    }

    String getLocationTypeText() {
      switch (location.type) {
        case 'subway':
          return '지하철';
        case 'bus':
          return '버스';
        case 'map':
          return '지도';
        default:
          return '위치';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            getLocationIcon(),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  '$label • ${getLocationTypeText()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.close,
              color: color,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildOrangeTransferButton({
    required VoidCallback onTap,
    required int count,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFF97316).withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: const Color(0xFFF97316),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '환승지 추가 ($count/3)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartureButton({
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: const Color(0xFF3B82F6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '출발지 설정',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrivalButton({
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: const Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '도착지 설정',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCustomBottomBar(RxnString selectedDeparture, RxnString selectedArrival) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final bool canProceed = selectedDeparture.value != null &&
            selectedArrival.value != null;

        return GestureDetector(
          onTap: canProceed ? () {
            controller.nextStep();
          } : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: canProceed ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF3B82F6), // 파란색
                  Color(0xFF6366F1), // 인디고색
                ],
              ) : null,
              color: canProceed ? null : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
              boxShadow: canProceed ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: const Center(
              child: Text(
                '다음 단계',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}