import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import 'steps/step_welcome.dart';
import 'steps/step_route_setup.dart';
import 'steps/step_work_time_setup.dart';
import 'steps/step_notification_setup.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.currentStep.value) {
        case 0:
          return const StepWelcome();
        case 1:
          return const StepRouteSetup();
        case 2:
          return const StepWorkTimeSetup();
        case 3:
          return const StepNotificationSetup();
        default:
          return const StepWelcome();
      }
    });
  }
}