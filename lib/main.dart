import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'core/di/inject_provider.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';

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

  // 카카오맵 WebView 플러그인 초기화
  try {
    AuthRepository.initialize(
      appKey: dotenv.env['KAKAO_JAVASCRIPT_KEY'] ?? dotenv.env['KAKAO_REST_API_KEY'] ?? '',
    );
    print('카카오맵 초기화 완료');
  } catch (e) {
    print('카카오맵 초기화 실패: $e');
  }

  // 로컬 저장소 초기화
  await GetStorage.init();

  // DI 컨테이너 초기화
  await setupDependencies();

  print('=== 앱 시작 ===');
  print('저장소 초기화 완료');

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