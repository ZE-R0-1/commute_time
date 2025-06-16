import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// 앱바
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      title: Row(
        children: [
          Icon(
            Icons.directions_subway_rounded,
            color: Get.theme.colorScheme.primary,
            size: 28.w,
          ),
          SizedBox(width: 8.w),
          Text(
            '출퇴근타임',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: Get.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: controller.checkNotifications,
          icon: Icon(
            Icons.notifications_outlined,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: controller.goToSettings,
          icon: Icon(
            Icons.settings_outlined,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// 메인 바디
  Widget _buildBody() {
    return Obx(() => IndexedStack(
      index: controller.selectedTabIndex.value,
      children: [
        _buildHomeTab(),
        _buildSearchTab(),
        _buildFavoritesTab(),
        _buildProfileTab(),
      ],
    ));
  }

  /// 홈 탭
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 시간 카드
          _buildTimeCard(),

          SizedBox(height: 24.h),

          // 빠른 검색
          _buildQuickSearch(),

          SizedBox(height: 32.h),

          // 최근 경로
          _buildRecentRoutes(),

          SizedBox(height: 24.h),

          // 교통 상황 (임시)
          _buildTrafficStatus(),
        ],
      ),
    );
  }

  /// 현재 시간 카드
  Widget _buildTimeCard() {
    return Obx(() => Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Get.theme.colorScheme.primary,
            Get.theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                '현재 시간',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Text(
            controller.currentTime.value,
            style: Get.textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 48.sp,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            controller.currentDate.value,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ));
  }

  /// 빠른 검색
  Widget _buildQuickSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 검색',
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 16.h),

        Container(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: controller.searchRoute,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.surface,
              foregroundColor: Get.theme.colorScheme.onSurface,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: Get.theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 24.w,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                SizedBox(width: 12.w),
                Text(
                  '출발지에서 도착지까지',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.w,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 최근 경로
  Widget _buildRecentRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 경로',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                '더보기',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        Obx(() => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.recentRoutes.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final route = controller.recentRoutes[index];
            return _buildRouteCard(route, index);
          },
        )),
      ],
    );
  }

  /// 경로 카드
  Widget _buildRouteCard(Map<String, dynamic> route, int index) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // 경로 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      route['from'],
                      style: Get.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward,
                      size: 16.w,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      route['to'],
                      style: Get.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        route['line'],
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Get.theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      route['time'],
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 즐겨찾기 버튼
          IconButton(
            onPressed: () => controller.toggleFavorite(index),
            icon: Icon(
              route['isFavorite'] ? Icons.star : Icons.star_border,
              color: route['isFavorite']
                  ? Colors.amber
                  : Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 교통 상황 (임시)
  Widget _buildTrafficStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '실시간 교통정보',
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 16.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Get.theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48.w,
                color: Get.theme.colorScheme.primary.withOpacity(0.7),
              ),
              SizedBox(height: 12.h),
              Text(
                '실시간 교통정보',
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '지하철 API 연동은 다음 단계에서 구현됩니다',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 검색 탭 (임시)
  Widget _buildSearchTab() {
    return const Center(
      child: Text('검색 화면 (다음 단계에서 구현)'),
    );
  }

  /// 즐겨찾기 탭 (임시)
  Widget _buildFavoritesTab() {
    return const Center(
      child: Text('즐겨찾기 화면 (다음 단계에서 구현)'),
    );
  }

  /// 프로필 탭 (임시)
  Widget _buildProfileTab() {
    return const Center(
      child: Text('프로필 화면 (다음 단계에서 구현)'),
    );
  }

  /// 하단 네비게이션
  Widget _buildBottomNavigation() {
    return Obx(() => BottomNavigationBar(
      currentIndex: controller.selectedTabIndex.value,
      onTap: controller.changeTab,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      selectedItemColor: Get.theme.colorScheme.primary,
      unselectedItemColor: Get.theme.colorScheme.onSurface.withOpacity(0.5),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: '검색',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star_outline),
          activeIcon: Icon(Icons.star),
          label: '즐겨찾기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '프로필',
        ),
      ],
    ));
  }
}