import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'location_search_controller.dart';

class LocationSearchScreen extends GetView<LocationSearchController> {
  const LocationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchTextController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
      body: Stack(
        children: [
          // 카카오맵 영역 (전체 화면)
          _buildMapSection(),
          
          // 상단 검색창과 카테고리 필터
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildSearchSection(searchTextController),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(TextEditingController searchController) {
    return Column(
      children: [
        // 검색창 (카카오맵 스타일)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: controller.performSearch,
            decoration: InputDecoration(
              hintText: '역이나 정류장 이름을 입력하세요',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 22,
              ),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () {
                        searchController.clear();
                        controller.performSearch('');
                      },
                    )
                  : const SizedBox.shrink()),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 카테고리 필터 (카카오맵 스타일)
        Row(
          children: [
            Obx(() => _buildKakaoCategoryButton(
              '지하철역',
              0,
              controller.selectedCategory.value,
              Icons.train,
              Colors.blue,
            )),
            const SizedBox(width: 8),
            Obx(() => _buildKakaoCategoryButton(
              '버스정류장',
              1,
              controller.selectedCategory.value,
              Icons.directions_bus,
              Colors.green,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildKakaoCategoryButton(String title, int index, int selectedIndex, IconData icon, Color color) {
    bool isSelected = index == selectedIndex;
    
    return GestureDetector(
      onTap: () => controller.changeCategory(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 12,
                color: isSelected ? color : color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return KakaoMap(
      key: const ValueKey('location_search_map'), // 고유 키 추가
      onMapCreated: controller.onMapCreated,
      center: LatLng(37.4980, 127.0276), // 강남역 중심
      minLevel: 3,
      maxLevel: 3,
      markers: controller.markers,
    );
  }

}