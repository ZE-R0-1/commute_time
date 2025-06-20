import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 커스텀 상단 영역
              _buildHeader(),

              // 메인 콘텐츠
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 날씨 알림 카드
                    _buildWeatherCard(),

                    const SizedBox(height: 20),

                    // 출근 정보 카드
                    _buildCommuteCard(),

                    const SizedBox(height: 16),

                    // 퇴근 정보 카드
                    _buildReturnCard(),

                    const SizedBox(height: 20),

                    // 교통 상황
                    _buildTransportStatus(),

                    // 하단 여백
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 커스텀 헤더
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Get.theme.primaryColor,
            Get.theme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 아이콘들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 알림 아이콘
                  IconButton(
                    onPressed: () {
                      // TODO: 알림 화면으로 이동
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // 프로필 아이콘
                  IconButton(
                    onPressed: () {
                      // TODO: 프로필 화면으로 이동
                    },
                    icon: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 인사말 - 직접 getter 호출 (Obx 제거)
              Text(
                controller.greetingMessage,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // 서브텍스트 - 직접 getter 호출 (Obx 제거)
              Text(
                controller.subGreetingMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 날씨 알림 카드
  Widget _buildWeatherCard() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.yellow[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wb_cloudy,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.weatherInfo.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.weatherAdvice.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    ));
  }

  // 출근 정보 카드 (상세 버튼 추가)
  Widget _buildCommuteCard() {
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
          // 제목과 상세 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '🌅 오늘 출근',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // 상세 버튼 추가
              InkWell(
                onTap: controller.showCommuteRouteDetail,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '상세',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 권장 출발시간
          Obx(() => Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.recommendedDepartureTime.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )),

          const SizedBox(height: 16),

          // 경로 정보
          Obx(() => _buildInfoRow(
            Icons.route,
            '경로',
            controller.commuteRoute.value,
          )),

          const SizedBox(height: 12),

          // 소요시간
          Obx(() => _buildInfoRow(
            Icons.access_time,
            '예상 소요시간',
            controller.estimatedTime.value,
          )),

          const SizedBox(height: 12),

          // 교통비
          Obx(() => _buildInfoRow(
            Icons.payments,
            '교통비',
            controller.transportFee.value,
          )),
        ],
      ),
    );
  }

  // 퇴근 정보 카드 (상세 버튼 추가)
  Widget _buildReturnCard() {
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
          // 제목과 상세 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.nights_stay,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '🌆 오늘 퇴근',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // 상세 버튼 추가
              InkWell(
                onTap: controller.showReturnRouteDetail,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '상세',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[600],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 권장 퇴근시간
          Obx(() => Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.recommendedOffTime.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )),

          const SizedBox(height: 16),

          // 일정 고려사항
          Obx(() => _buildInfoRow(
            Icons.event,
            '일정 고려',
            controller.eveningSchedule.value,
          )),

          const SizedBox(height: 12),

          // 여유시간
          Obx(() => _buildInfoRow(
            Icons.schedule,
            '여유 시간',
            controller.bufferTime.value,
          )),
        ],
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // 교통 상황
  Widget _buildTransportStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚇 교통 상황',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: controller.transportStatus.length,
          itemBuilder: (context, index) {
            final transport = controller.transportStatus[index];
            return _buildTransportStatusCard(transport);
          },
        )),
      ],
    );
  }

  // 교통 상황 카드
  Widget _buildTransportStatusCard(TransportStatus transport) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: transport.color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: transport.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transport.icon,
              color: transport.color,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          // 교통수단명
          Text(
            transport.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // 상태
          Text(
            transport.statusText,
            style: TextStyle(
              fontSize: 12,
              color: transport.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}