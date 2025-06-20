import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'map_controller.dart';

class MapScreen extends GetView<MapController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('경로 지도'),
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.refreshMap,
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 지도 영역 (상단 60%)
          Expanded(
            flex: 3,
            child: _buildMapArea(),
          ),

          // 하단 컨트롤 영역 (하단 40%)
          Expanded(
            flex: 2,
            child: _buildControlArea(),
          ),
        ],
      ),
    );
  }

  // 지도 영역
  Widget _buildMapArea() {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      child: Stack(
        children: [
          // 지도 배경
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[400]!,
                  width: 1,
                ),
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🗺️',
                    style: TextStyle(
                      fontSize: 48,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '카카오맵 - 출퇴근 경로',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '실제 서비스에서는 카카오맵이 표시됩니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 집 마커 (좌측 상단)
          Positioned(
            top: 40,
            left: 40,
            child: _buildMapMarker(
              color: Colors.green,
              icon: '🏠',
              label: '집',
            ),
          ),

          // 회사 마커 (우측 하단)
          Positioned(
            bottom: 80,
            right: 40,
            child: _buildMapMarker(
              color: Colors.red,
              icon: '🏢',
              label: '회사',
            ),
          ),

          // 현재위치 마커 (중앙)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() => _buildMapMarker(
                color: Colors.blue,
                icon: '📍',
                label: controller.isLoadingLocation.value ? '위치 확인 중...' : '현재위치',
                isLoading: controller.isLoadingLocation.value,
              )),
            ),
          ),
        ],
      ),
    );
  }

  // 지도 마커
  Widget _buildMapMarker({
    required Color color,
    required String icon,
    required String label,
    bool isLoading = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 마커 아이콘
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Center(
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // 마커 라벨
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // 하단 컨트롤 영역
  Widget _buildControlArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 위치 정보 카드들
            Column(
              children: [
                // 집 위치 카드
                Obx(() => _buildLocationCard(
                  icon: '🏠',
                  iconColor: Colors.green,
                  title: '우리집',
                  address: controller.homeAddress.value,
                  onEdit: controller.editHomeAddress,
                )),

                const SizedBox(height: 12),

                // 회사 위치 카드
                Obx(() => _buildLocationCard(
                  icon: '🏢',
                  iconColor: Colors.red,
                  title: '회사',
                  address: controller.workAddress.value,
                  onEdit: controller.editWorkAddress,
                )),

                const SizedBox(height: 16),

                // 현재 위치 정보
                Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '📍',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '현재 위치',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.currentLocation.value,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.isLoadingLocation.value)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                      else
                        IconButton(
                          onPressed: controller.refreshCurrentLocation,
                          icon: Icon(
                            Icons.my_location,
                            color: Colors.blue[600],
                            size: 18,
                          ),
                          tooltip: '현재 위치 새로고침',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                )),

                const SizedBox(height: 16),

                // 액션 버튼들
                Column(
                  children: [
                    // 경로 검색 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isSearchingRoute.value
                            ? null
                            : controller.searchRoute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: controller.isSearchingRoute.value
                            ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '경로 검색 중...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.route, size: 18),
                            SizedBox(width: 6),
                            Text(
                              '경로 검색',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ),

                    const SizedBox(height: 10),

                    // 즐겨찾는 경로 추가 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton(
                        onPressed: controller.addFavoriteRoute,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_outline, size: 16),
                            SizedBox(width: 6),
                            Text(
                              '즐겨찾는 경로 추가',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 위치 카드
  Widget _buildLocationCard({
    required String icon,
    required Color iconColor,
    required String title,
    required String address,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 수정 버튼
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              foregroundColor: iconColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: iconColor.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: const Text(
              '수정',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}