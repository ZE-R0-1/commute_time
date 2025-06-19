import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'route_detail_controller.dart';
import 'widgets/route_header.dart';
import 'widgets/route_time_line.dart';
import 'widgets/alternative_routes.dart';

class RouteDetailScreen extends GetView<RouteDetailController> {
  const RouteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        return CustomScrollView(
          slivers: [
            // 앱바
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: false,
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                controller.routeType.value == 'morning' ? '출근 경로' : '퇴근 경로',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // TODO: 메뉴 기능 구현
                    _showOptionsMenu(context);
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),

            // 메인 콘텐츠
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // 경로 헤더
                  const RouteHeader(),

                  // 상세 경로 타임라인
                  const RouteTimeline(),

                  // 대안 경로들
                  const AlternativeRoutes(),

                  // 하단 여백
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          controller.routeType.value == 'morning' ? '출근 경로' : '퇴근 경로',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // 로딩 헤더 스켈레톤
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.primaryColor,
                  Get.theme.primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '경로 정보를 불러오는 중...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 로딩 콘텐츠 스켈레톤
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSkeletonCard(height: 100),
                  const SizedBox(height: 16),
                  _buildSkeletonCard(height: 80),
                  const SizedBox(height: 16),
                  _buildSkeletonCard(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.grey[200]!,
              Colors.grey[100]!,
              Colors.grey[200]!,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // 메뉴 항목들
            _buildMenuOption(
              icon: Icons.refresh,
              title: '실시간 정보 새로고침',
              onTap: () {
                Get.back();
                controller.refreshRealTimeInfo();
              },
            ),
            _buildMenuOption(
              icon: Icons.star_border,
              title: '즐겨찾기에 추가',
              onTap: () {
                Get.back();
                controller.addToFavorites();
              },
            ),
            _buildMenuOption(
              icon: Icons.share,
              title: '경로 공유하기',
              onTap: () {
                Get.back();
                Get.snackbar(
                  '공유',
                  '경로 정보를 공유합니다.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Get.theme.primaryColor,
                  colorText: Colors.white,
                );
              },
            ),
            _buildMenuOption(
              icon: Icons.bug_report,
              title: '문제 신고하기',
              onTap: () {
                Get.back();
                Get.snackbar(
                  '신고',
                  '문제를 신고해주셔서 감사합니다.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Get.theme.primaryColor,
                  colorText: Colors.white,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}