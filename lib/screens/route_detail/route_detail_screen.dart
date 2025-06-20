import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'route_detail_controller.dart';

class RouteDetailScreen extends GetView<RouteDetailController> {
  const RouteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 상단 헤더
          _buildHeader(),

          // 스크롤 가능한 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 권장 출발시간 카드
                  _buildRecommendedTimeCard(),

                  const SizedBox(height: 24),

                  // 상세 경로 타임라인
                  _buildRouteTimeline(),

                  const SizedBox(height: 24),

                  // 하단 요약 정보
                  _buildSummaryGrid(),

                  // 액션 버튼들
                  const SizedBox(height: 32),
                  _buildActionButtons(),

                  // 하단 여백
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 상단 헤더
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 뒤로가기 버튼
          IconButton(
            onPressed: controller.goBack,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(width: 16),

          // 제목
          Expanded(
            child: Text(
              controller.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // 즐겨찾기 버튼
          IconButton(
            onPressed: controller.addToFavorites,
            icon: const Icon(
              Icons.star_border,
              color: Colors.white,
            ),
            tooltip: '즐겨찾기 추가',
          ),

          // 공유 버튼
          IconButton(
            onPressed: controller.shareRoute,
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
            tooltip: '경로 공유',
          ),
        ],
      ),
    );
  }

  // 권장 출발시간 카드
  Widget _buildRecommendedTimeCard() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Get.theme.primaryColor,
            Get.theme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Get.theme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '권장 출발시간',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            controller.recommendedTime.value,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            controller.timeDescription.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ));
  }

  // 상세 경로 타임라인
  Widget _buildRouteTimeline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📍 상세 경로',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // 타임라인
          Obx(() => Column(
            children: controller.routeSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == controller.routeSteps.length - 1;

              return _buildTimelineStep(step, isLast);
            }).toList(),
          )),
        ],
      ),
    );
  }

  // 타임라인 단계
  Widget _buildTimelineStep(RouteStep step, bool isLast) {
    return InkWell(
      onTap: () => controller.showStepDetail(step),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타임라인 마커와 연결선
            Column(
              children: [
                // 마커
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: step.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: step.color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // 연결선 (마지막이 아닌 경우)
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          step.color.withValues(alpha: 0.5),
                          Colors.grey[300]!,
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // 단계 정보
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: step.color.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목과 아이콘
                    Row(
                      children: [
                        Text(
                          step.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: step.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            step.duration,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 설명
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    // 추가 정보 (있는 경우)
                    if (step.details != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.details!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 하단 요약 정보 그리드
  Widget _buildSummaryGrid() {
    return Row(
      children: [
        // 총 소요시간
        Expanded(
          child: Obx(() => _buildSummaryCard(
            icon: Icons.schedule,
            iconColor: Colors.blue,
            title: '총 소요시간',
            value: controller.totalDuration.value,
            backgroundColor: Colors.blue[50]!,
          )),
        ),

        const SizedBox(width: 16),

        // 교통비
        Expanded(
          child: Obx(() => _buildSummaryCard(
            icon: Icons.account_balance_wallet,
            iconColor: Colors.green,
            title: '교통비',
            value: controller.totalCost.value,
            backgroundColor: Colors.green[50]!,
          )),
        ),
      ],
    );
  }

  // 요약 카드
  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: iconColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 액션 버튼들
  Widget _buildActionButtons() {
    return Row(
      children: [
        // 대안 경로 보기
        Expanded(
          child: OutlinedButton(
            onPressed: controller.showAlternativeRoutes,
            style: OutlinedButton.styleFrom(
              foregroundColor: Get.theme.primaryColor,
              side: BorderSide(color: Get.theme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.alt_route, size: 18),
                SizedBox(width: 8),
                Text(
                  '대안 경로',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 네비게이션 시작
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Get.snackbar(
                '네비게이션 시작',
                '선택하신 경로로 안내를 시작합니다.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Get.theme.primaryColor,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
                icon: const Icon(Icons.navigation, color: Colors.white),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.navigation, size: 18),
                SizedBox(width: 8),
                Text(
                  '길찾기 시작',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}