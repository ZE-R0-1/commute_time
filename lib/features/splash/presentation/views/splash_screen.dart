import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';
import 'components/splash_logo.dart';
import 'components/splash_title.dart';
import 'components/splash_subtitle.dart';
import 'components/splash_loading.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              const SplashLogo(),

              SizedBox(height: 24.h),

              // 앱 제목
              const SplashTitle(),

              SizedBox(height: 8.h),

              // 부제목
              const SplashSubtitle(),

              SizedBox(height: 80.h),

              // 로딩 인디케이터
              const SplashLoading(),
            ],
          ),
        ),
      ),
    );
  }
}