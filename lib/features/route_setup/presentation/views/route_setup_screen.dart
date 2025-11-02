import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/route_setup_controller.dart';
import 'components/route_list/route_list.dart';

class RouteSetupScreen extends GetView<RouteSetupController> {
  const RouteSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 제목
              Text(
                '저장된 출퇴근 경로',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              const SizedBox(height: 8),

              Obx(() {
                final routeCount = controller.routesList.length;
                return Text(
                  routeCount > 0 ? '총 ${routeCount}개의 경로가 저장되어 있습니다' : '아직 저장된 경로가 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // 경로 목록
              RouteList(controller: controller),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.addNewRoute();
        },
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}