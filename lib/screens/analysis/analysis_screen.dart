import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'analysis_controller.dart';

class AnalysisScreen extends GetView<AnalysisController> {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출퇴근 분석'),
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.refreshAnalysis,
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: controller.refreshAnalysis,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 제목
              const Text(
                '📊 이번 달 통근 분석',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // 핵심 지표 카드
              _buildKeyMetricCard(),

              const SizedBox(height: 20),

              // 평균 시간 그리드
              _buildAverageTimeGrid(),

              const SizedBox(height: 24),

              // 요일별 패턴 차트
              _buildWeeklyPatternChart(),

              const SizedBox(height: 24),

              // 교통비 분석
              _buildTransportCostAnalysis(),

              // 하단 여백
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // 핵심 지표 카드
  Widget _buildKeyMetricCard() {
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
          const Icon(
            Icons.timer_outlined,
            color: Colors.white,
            size: 32,
          ),

          const SizedBox(height: 12),

          Text(
            controller.savedTime.value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '이번 달 절약한 시간',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '최적 경로 선택으로 시간 단축 성공! 🎉',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // 평균 시간 그리드
  Widget _buildAverageTimeGrid() {
    return Row(
      children: [
        // 출근 소요시간
        Expanded(
          child: Obx(() => _buildTimeCard(
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            title: '출근 소요시간',
            time: controller.avgCommuteTime.value,
            backgroundColor: Colors.orange[50]!,
          )),
        ),

        const SizedBox(width: 16),

        // 퇴근 소요시간
        Expanded(
          child: Obx(() => _buildTimeCard(
            icon: Icons.nights_stay,
            iconColor: Colors.purple,
            title: '퇴근 소요시간',
            time: controller.avgReturnTime.value,
            backgroundColor: Colors.purple[50]!,
          )),
        ),
      ],
    );
  }

  // 시간 카드
  Widget _buildTimeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
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
            time,
            style: TextStyle(
              fontSize: 28,
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

  // 요일별 패턴 차트
  Widget _buildWeeklyPatternChart() {
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
            '📈 요일별 패턴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // 차트 영역
          Obx(() => _buildWeeklyChart()),

          const SizedBox(height: 16),

          // 범례
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend(Colors.blue, '출근시간'),
              const SizedBox(width: 20),
              _buildChartLegend(Colors.green, '퇴근시간'),
            ],
          ),
        ],
      ),
    );
  }

  // 요일별 차트 (간단한 막대그래프)
  Widget _buildWeeklyChart() {
    if (controller.weeklyPattern.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                '차트 영역',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '요일별 통근 시간 패턴이 표시됩니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: controller.weeklyPattern.map((data) {
          return _buildBarChart(data);
        }).toList(),
      ),
    );
  }

  // 막대 차트 요소
  Widget _buildBarChart(WeeklyPatternData data) {
    final maxTime = 70; // 최대 시간 (70분)
    final commuteHeight = (data.commuteTime / maxTime * 160).clamp(10, 160).toDouble();
    final returnHeight = (data.returnTime / maxTime * 160).clamp(10, 160).toDouble();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 시간 표시
        Column(
          children: [
            Text(
              '${data.commuteTime}분',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
            Text(
              '${data.returnTime}분',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // 막대 그래프
        Row(
          children: [
            // 출근시간 막대
            Container(
              width: 12,
              height: commuteHeight,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            const SizedBox(width: 4),

            // 퇴근시간 막대
            Container(
              width: 12,
              height: returnHeight,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 요일
        Text(
          data.day,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 차트 범례
  Widget _buildChartLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 교통비 분석
  Widget _buildTransportCostAnalysis() {
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
            '💰 교통비 분석',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // 교통비 정보들
          Obx(() => Column(
            children: [
              // 이번 달 총 교통비
              _buildCostItem(
                icon: Icons.account_balance_wallet,
                iconColor: Colors.blue,
                title: '이번 달 총 교통비',
                amount: controller.formatCurrency(controller.totalTransportCost.value),
                amountColor: Colors.black87,
              ),

              const SizedBox(height: 16),

              // 일평균 교통비
              _buildCostItem(
                icon: Icons.today,
                iconColor: Colors.orange,
                title: '일평균 교통비',
                amount: controller.formatCurrency(controller.dailyAvgCost.value),
                amountColor: Colors.black87,
              ),

              const SizedBox(height: 16),

              // 예상 절약 금액
              _buildCostItem(
                icon: Icons.savings,
                iconColor: Colors.green,
                title: '예상 절약 금액',
                amount: '+${controller.formatCurrency(controller.expectedSaving.value)}',
                amountColor: Colors.green,
                isHighlight: true,
              ),
            ],
          )),

          const SizedBox(height: 20),

          // 절약률 표시
          Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이번 달 절약률',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${controller.savingPercentage.toStringAsFixed(1)}% 절약했어요!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // 교통비 아이템
  Widget _buildCostItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required Color amountColor,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? iconColor.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isHighlight
            ? Border.all(color: iconColor.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}