import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경변수 파일 로드
  try {
    await dotenv.load(fileName: ".env");
    print('환경변수 로드 완료');
  } catch (e) {
    print('환경변수 로드 실패: $e');
    print('기본값으로 진행합니다.');
  }

  // 로컬 저장소 초기화
  await GetStorage.init();

  // 테스트용: 앱 상태 초기화 (개발 중에만 사용)
  final storage = GetStorage();

  // 🆕 로그인 제거로 인한 설정 변경
  // 테스트 시나리오 선택

  // 1. 🔥 메인 화면(탭바) 테스트용 - 온보딩 완료 상태로 설정
  storage.erase(); // 기존 데이터 삭제
  storage.write('onboarding_completed', false);
  storage.write('user_name', '김직장');
  storage.write('work_start_time', '09:00');
  storage.write('work_end_time', '18:00');

  // 2. 온보딩 화면 테스트용 (위 코드 주석 처리하고 아래 코드 사용)
  // storage.erase(); // 모든 데이터 삭제 (첫 실행 테스트)

  print('=== 앱 시작 ===');
  print('저장소 초기화 완료');
  print('메인 화면(탭바) 테스트 모드');

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 화면 방향 고정 (세로모드만)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const CommuteTimeApp());
}

class CommuteTimeApp extends StatelessWidget {
  const CommuteTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 기준
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: '출퇴근타임',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
          locale: const Locale('ko', 'KR'),
          fallbackLocale: const Locale('ko', 'KR'),
        );
      },
    );
  }
}