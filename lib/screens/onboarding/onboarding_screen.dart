import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'onboarding_controller.dart';
import 'widgets/step_route_setup.dart';
import 'widgets/step_work_time_setup.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.currentStep.value) {
        case 0:
          return _buildWelcomeScreen();
        case 1:
          return const StepRouteSetup();
        case 2:
          return const StepWorkTimeSetup();
        default:
          return _buildWelcomeScreen();
      }
    });
  }

  Widget _buildWelcomeScreen() {
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
        child: SafeArea(
          child: Column(
            children: [
              // 헤더 영역
              Expanded(
                flex: 3,
                child: _buildHeader(),
              ),
              
              // 기능 소개 카드들
              Expanded(
                flex: 4,
                child: _buildFeatureCards(),
              ),
              
              // 하단 영역
              Expanded(
                flex: 2,
                child: _buildBottomSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 앱 아이콘
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.7 + (0.3 * value),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2196F3), // 파란색
                        Color(0xFF3F51B5), // 인디고색
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2196F3).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // 앱 제목
          Text(
            '출퇴근 도우미',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // 부제목
          Text(
            '스마트한 출퇴근을 위한 실시간 정보',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // 첫 번째 카드: 실시간 교통정보
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildFeatureCard(
                    icon: Icons.access_time,
                    iconColor: const Color(0xFF2196F3),
                    title: '실시간 교통정보',
                    description: '지하철, 버스, 도로 상황을 한눈에',
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // 두 번째 카드: 스마트 알림
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildFeatureCard(
                    icon: Icons.notifications,
                    iconColor: const Color(0xFF4CAF50),
                    title: '스마트 알림',
                    description: '출발 시간을 미리 알려드려요',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 텍스트 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 시작하기 버튼
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: Opacity(
                  opacity: value,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.nextStep();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF2196F3), // 파란색
                              Color(0xFF3F51B5), // 인디고색
                            ],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: const Center(
                          child: Text(
                            '시작하기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // 설명 텍스트
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  '무료로 시작하고 언제든 설정을 변경할 수 있어요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}