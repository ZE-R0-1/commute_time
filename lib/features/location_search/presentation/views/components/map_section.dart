import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../../controllers/location_search_controller.dart';
import 'research_button.dart';

/// 지도 섹션 컴포넌트
class MapSection extends GetView<LocationSearchController> {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationSearchController>(
      builder: (ctrl) => Stack(
        children: [
          // 마커가 업데이트될 때마다 KakaoMap 재빌드
          KakaoMap(
            key: const ValueKey('location_search_map'),
            onMapCreated: ctrl.onMapCreated,
            center: LatLng(37.4980, 127.0276), // 강남역 중심
            minLevel: 3,
            maxLevel: 3,
            markers: ctrl.markers,
            onMarkerTap: ctrl.onMarkerTap,
            onDragChangeCallback: ctrl.onDragChange,
          ),
          Obx(() => ResearchButton(
            isVisible: ctrl.showResearchButton.value,
            onTap: ctrl.onResearchButtonTap,
          )),
        ],
      ),
    );
  }
}