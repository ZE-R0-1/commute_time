import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'widgets/login_button.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고 및 제목 섹션
                    _buildHeaderSection(),

                    SizedBox(height: 60.h),

                    // 로그인 버튼 섹션
                    _buildLoginButtonsSection(),

                    SizedBox(height: 32.h),

                    // 이메일 로그인 링크
                    _buildEmailLoginLink(),
                  ],
                ),
              ),

              // 하단 약관 텍스트
              _buildTermsSection(),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // 로고
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Get.theme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '🚇',
                    style: TextStyle(fontSize: 40.sp),
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 24.h),

        // 앱 제목
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: Text(
                  '출퇴근타임',
                  style: Get.textTheme.headlineLarge?.copyWith(
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 8.h),

        // 부제목
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: Text(
                  '스마트한 출퇴근의 시작',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoginButtonsSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 30),
            child: Column(
              children: [
                // 카카오 로그인 버튼
                Obx(() => KakaoLoginButton(
                  onPressed: controller.signInWithKakao,
                  isLoading: controller.isLoading.value &&
                      controller.loadingMessage.value.contains('카카오'),
                )),

                // 구글 로그인 버튼
                Obx(() => GoogleLoginButton(
                  onPressed: controller.signInWithGoogle,
                  isLoading: controller.isLoading.value &&
                      controller.loadingMessage.value.contains('구글'),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailLoginLink() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: TextButton(
            onPressed: () {
              // Mock: 이메일 로그인 (추후 구현)
              Get.snackbar(
                '준비 중',
                '이메일 로그인은 곧 지원될 예정입니다.',
                snackPosition: SnackPosition.TOP,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            child: Text(
              '이메일로 로그인',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Get.theme.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
                height: 1.4,
              ),
              children: [
                const TextSpan(text: '로그인하면 '),
                TextSpan(
                  text: '이용약관',
                  style: TextStyle(
                    color: Get.theme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' 및 '),
                TextSpan(
                  text: '개인정보처리방침',
                  style: TextStyle(
                    color: Get.theme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: '에\n동의하는 것으로 간주됩니다.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

// 로딩 오버레이 (필요시 사용)
class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Get.theme.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                style: Get.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}