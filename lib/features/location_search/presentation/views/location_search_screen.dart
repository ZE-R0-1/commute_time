import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../controllers/location_search_controller.dart';
import '../controllers/search_result_controller.dart';
import 'search_result_screen.dart';
import 'components/search_header_section.dart';
import 'components/map_section.dart';

class LocationSearchScreen extends GetView<LocationSearchController> {
  const LocationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // 지도 섹션
          const MapSection(),

          // 검색 헤더 섹션 (상단에 오버레이)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Obx(() => SearchHeaderSection(
              onSearchTap: _openSearchScreen,
              selectedCategory: controller.selectedCategory.value,
              onCategoryChanged: controller.changeCategory,
            )),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: Obx(() => Text(
        controller.title.value,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      )),
      centerTitle: true,
    );
  }

  void _openSearchScreen() async {
    try {
      // SearchResultController를 등록 (이미 존재하면 재사용)
      if (!Get.isRegistered<SearchResultController>()) {
        Get.put(SearchResultController());
      }

      // 검색 화면으로 이동하고 결과 대기
      final result = await Get.to(() => const SearchResultScreen());

      // 결과가 있으면 처리
      if (result != null && result is Map<String, dynamic>) {
        _handleSearchResult(result);
      }
    } catch (e) {
      print('❌ 검색 화면 오류: $e');
    } finally {
      // SearchResultController 정리 (안전하게)
      try {
        if (Get.isRegistered<SearchResultController>()) {
          Get.delete<SearchResultController>();
        }
      } catch (e) {
        print('❌ 컨트롤러 정리 오류: $e');
      }
    }
  }

  void _handleSearchResult(Map<String, dynamic> result) async {
    // 지도 중심을 선택된 위치로 이동
    final latitude = result['latitude'] as double?;
    final longitude = result['longitude'] as double?;

    if (latitude != null && longitude != null && controller.mapController != null) {
      await controller.mapController!.setCenter(LatLng(latitude, longitude));
      print('📍 선택된 위치로 지도 이동: (${latitude}, ${longitude})');
      print('🏷️ 선택된 장소: ${result['title']}');

      // 지도 이동 후 현재 선택된 카테고리에 따라 마커 표시
      await controller.refreshMarkersAfterMove();
    }
  }
}