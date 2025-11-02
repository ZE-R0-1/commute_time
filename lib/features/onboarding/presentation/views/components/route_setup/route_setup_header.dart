import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/onboarding_controller.dart';

class RouteSetupHeader extends StatelessWidget {
  final bool isAddNewMode;
  final String? customTitle;

  const RouteSetupHeader({
    super.key,
    required this.isAddNewMode,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => isAddNewMode
                ? Get.back()
                : (Get.isRegistered<OnboardingController>()
                    ? Get.find<OnboardingController>().previousStep()
                    : Get.back()),
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
                Text(
                  customTitle ?? '경로 설정',
                  style: const TextStyle(
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
}