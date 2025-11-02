import 'package:flutter/material.dart';
import 'welcome_feature_card.dart';

class WelcomeFeatureCards extends StatelessWidget {
  const WelcomeFeatureCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // 첫 번째 카드: 실시간 교통정보
          WelcomeFeatureCard(
            icon: Icons.access_time,
            iconColor: const Color(0xFF2196F3),
            title: '실시간 교통정보',
            description: '지하철, 버스, 도로 상황을 한눈에',
            delay: const Duration(milliseconds: 600),
          ),

          const SizedBox(height: 16),

          // 두 번째 카드: 스마트 알림
          WelcomeFeatureCard(
            icon: Icons.notifications,
            iconColor: const Color(0xFF4CAF50),
            title: '스마트 알림',
            description: '출발 시간을 미리 알려드려요',
            delay: const Duration(milliseconds: 800),
          ),
        ],
      ),
    );
  }
}