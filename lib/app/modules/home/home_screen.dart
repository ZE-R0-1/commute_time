import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_controller.dart';
import '../../data/models/subway_arrival_model.dart';
import '../../widgets/ping_pong_text.dart';

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
        // 새로고침 버튼
        Obx(() => IconButton(
          onPressed: controller.isLoadingSubway.value
              ? null
              : controller.refreshSubwayInfo,
          icon: controller.isLoadingSubway.value
              ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Get.theme.colorScheme.primary,
            ),
          )
              : Icon(
            Icons.refresh,
            color: Get.theme.colorScheme.primary,
          ),
        )),
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

          // 역 선택
          _buildStationSelector(),

          SizedBox(height: 20.h),

          // 실시간 지하철 정보
          _buildRealtimeSubwayInfo(),

          SizedBox(height: 32.h),

          // 자주 찾는 역
          _buildFavoriteStations(),

          SizedBox(height: 24.h),

          // 빠른 검색
          _buildQuickSearch(),
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
              const Spacer(),
              Icon(
                Icons.train,
                color: Colors.white.withOpacity(0.7),
                size: 20.w,
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

  /// 역 선택기
  Widget _buildStationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '실시간 지하철 정보',
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12.h),

        Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Get.theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Get.theme.colorScheme.primary,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${controller.selectedStation.value}역',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Get.theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 8.w),
              if (controller.isLoadingSubway.value) ...[
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ],
          ),
        )),
      ],
    );
  }

  /// 실시간 지하철 정보
  Widget _buildRealtimeSubwayInfo() {
    return Obx(() {
      if (controller.isLoadingSubway.value) {
        return _buildLoadingCard();
      }

      if (controller.realtimeArrivals.isEmpty) {
        return _buildNoDataCard();
      }

      return Column(
        children: controller.realtimeArrivals
            .take(6) // 최대 6개만 표시
            .map((arrival) => _buildArrivalCard(arrival))
            .toList(),
      );
    });
  }

  /// 로딩 카드
  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: Get.theme.colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            '실시간 정보를 불러오는 중...',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 데이터 없음 카드
  Widget _buildNoDataCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
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
            color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            '실시간 정보 없음',
            style: Get.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${controller.selectedStation.value}역의 실시간 도착정보가 없습니다',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 도착 정보 카드
  Widget _buildArrivalCard(SubwayArrival arrival) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(int.parse(arrival.lineColor.replaceFirst('#', '0xFF')))
              .withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse(arrival.lineColor.replaceFirst('#', '0xFF')))
                .withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 노선 정보
          Row(
            children: [
              // 노선 배지
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Color(int.parse(arrival.lineColor.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  arrival.subwayNm,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // 방향 정보 - 왕복 스크롤 효과 적용
              Expanded(
                child: _buildAnimatedText(
                  '${arrival.directionText} • ${arrival.trainLineNm}',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // 상태 아이콘
              Icon(
                arrival.arvlCd == '1' ? Icons.train : Icons.schedule,
                size: 16.w,
                color: arrival.arvlCd == '1'
                    ? Colors.green
                    : Get.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 도착 시간 정보
          Row(
            children: [
              // 첫 번째 도착
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '다음 열차',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    _buildAnimatedText(
                      controller.formatArrivalTime(arrival),
                      style: Get.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: arrival.cleanArrivalMessage.contains('곧')
                            ? Colors.red
                            : Get.theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 16.w),

              // 두 번째 도착 (있는 경우)
              if (arrival.arvlMsg3.isNotEmpty) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '그 다음',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _buildAnimatedText(
                        arrival.arvlMsg3.replaceAll('후 도착', '').trim(),
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 왕복 스크롤이 적용된 텍스트 위젯 (마키 효과 대체)
  Widget _buildAnimatedText(String text, {TextStyle? style, double? height}) {
    return TextAnimationHelper.buildAutoText(
      text,
      style: style ?? Get.textTheme.bodyMedium,
      height: height,
      maxLength: 15, // 15자 초과 시 왕복 스크롤
      animationDuration: const Duration(milliseconds: 2500), // 2.5초에 걸쳐 이동 (빨라짐!)
      pauseDuration: const Duration(milliseconds: 1200), // 양끝에서 1.2초 멈춤 (빨라짐!)
    );
  }

  /// 자주 찾는 역
  Widget _buildFavoriteStations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자주 찾는 역',
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12.h),

        Obx(() => Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: controller.favoriteStations
              .asMap()
              .entries
              .map((entry) => _buildStationChip(entry.value, entry.key))
              .toList(),
        )),
      ],
    );
  }

  /// 역 칩
  Widget _buildStationChip(Map<String, dynamic> station, int index) {
    final isSelected = controller.selectedStation.value == station['name'];

    return GestureDetector(
      onTap: () => controller.changeStation(station['name']),
      child: Container(
        constraints: BoxConstraints(maxWidth: 120.w), // 최대 너비 제한
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${station['name']}역',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : Get.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: () => controller.toggleFavorite(index),
              child: Icon(
                station['isFavorite'] ? Icons.star : Icons.star_border,
                size: 16.w,
                color: station['isFavorite']
                    ? (isSelected ? Colors.white : Colors.amber)
                    : Get.theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
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