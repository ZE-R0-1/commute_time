import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';
import '../components/welcome/welcome_bottom_button.dart';
import '../components/welcome/welcome_feature_cards.dart';
import '../components/welcome/welcome_header.dart';

class StepWelcome extends GetView<OnboardingController> {
  const StepWelcome({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: WelcomeHeader(),
              ),

              // 기능 소개 카드들
              Expanded(
                flex: 4,
                child: WelcomeFeatureCards(),
              ),

              // 하단 영역
              Expanded(
                flex: 2,
                child: WelcomeBottomButton(onPressed: () => controller.nextStep()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}