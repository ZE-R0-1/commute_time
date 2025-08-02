import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../onboarding_controller.dart';

class StepNotificationSetup extends GetView<OnboardingController> {
  const StepNotificationSetup({super.key});

  @override
  Widget build(BuildContext context) {
    // 로컬 상태 관리
    final RxBool departureNotification = true.obs;
    final RxBool weatherNotification = true.obs;
    
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
                        const SizedBox(height: 20),
                        
                        // 출발 시간 알림
                        Obx(() => _buildNotificationCard(
                          title: '출발 시간 알림',
                          subtitle: '출발할 시간을 미리 알려드려요',
                          icon: Icons.access_time,
                          color: const Color(0xFF3B82F6), // 파란색
                          isEnabled: departureNotification.value,
                          onToggle: (value) => departureNotification.value = value,
                        )),
                        
                        const SizedBox(height: 16),
                        
                        // 날씨 알림
                        Obx(() => _buildNotificationCard(
                          title: '날씨 알림',
                          subtitle: '우산이 필요한 날 미리 알림',
                          icon: Icons.wb_sunny,
                          color: const Color(0xFF10B981), // 초록색
                          isEnabled: weatherNotification.value,
                          onToggle: (value) => weatherNotification.value = value,
                        )),
                        
                        const SizedBox(height: 24),
                        
                        // 권한 안내 카드
                        _buildPermissionNoticeCard(),
                        
                        const SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),
                
                // 커스텀 하단 버튼
                _buildCustomBottomBar(departureNotification, weatherNotification),
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
                  '알림 설정',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '받고 싶은 알림을 선택해주세요',
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
                '3단계 중 3단계 완료',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '100%',
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
        final gapWidth = 8.0;
        final totalGaps = gapWidth * 2; // 3단계이므로 간격은 2개
        final segmentWidth = (totalWidth - totalGaps) / 3; // 3개의 세그먼트

        return Row(
          children: [
            // 1-3단계 (모두 완료)
            ...List.generate(3, (index) => [
              Container(
                width: segmentWidth,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              if (index < 2) SizedBox(width: gapWidth),
            ]).expand((x) => x),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required Function(bool) onToggle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionNoticeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '알림 권한 필요',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '실시간 정보를 받으려면 알림 권한을 허용해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomBar(RxBool departureNotification, RxBool weatherNotification) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          // 알림 설정을 컨트롤러에 저장
          // TODO: 알림 권한 요청 로직 추가
          
          // 온보딩 완료
          controller.nextStep();
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF3B82F6), // 파란색
                Color(0xFF6366F1), // 인디고색
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(59, 130, 246, 0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '설정 완료',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}