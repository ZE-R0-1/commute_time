import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginButton extends StatelessWidget {
  final String title;
  final String iconText; // 이모지나 아이콘 텍스트
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;
  final bool isLoading;

  const LoginButton({
    super.key,
    required this.title,
    required this.iconText,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.borderColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h,
      margin: EdgeInsets.only(bottom: 12.h),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 1)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              iconText,
              style: TextStyle(fontSize: 20.sp),
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 미리 정의된 로그인 버튼들
class KakaoLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const KakaoLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LoginButton(
      title: '카카오로 시작하기',
      iconText: '💬',
      backgroundColor: const Color(0xFFFEE500),
      textColor: const Color(0xFF3C1E1E),
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LoginButton(
      title: '구글로 시작하기',
      iconText: '🔍',
      backgroundColor: Colors.white,
      textColor: const Color(0xFF1F2937),
      borderColor: const Color(0xFFE5E7EB),
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}