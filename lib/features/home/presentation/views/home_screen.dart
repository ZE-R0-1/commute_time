import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/route_controller.dart';
import '../../../../../core/design_system/widgets/app_header_widget.dart';
import 'components/route/route_card.dart';
import 'components/weather/weather_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            const AppHeaderWidget(
              title: '안녕하세요!',
              subtitle: '오늘도 좋은 하루 되세요',
              actionIcon: Icons.notifications_outlined,
            ),

            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 경로 카드 (경로 데이터가 있을 때만)
                    Obx(() {
                      final routeCtrl = Get.find<RouteController>();
                      if (routeCtrl.hasRouteData.value) {
                        return const Column(
                          children: [
                            RouteCard(),
                            SizedBox(height: 24),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // 날씨 카드
                    const WeatherCard(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}