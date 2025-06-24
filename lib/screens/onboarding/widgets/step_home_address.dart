import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboarding_controller.dart';

class StepHomeAddress extends GetView<OnboardingController> {
  const StepHomeAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 🆕 집 아이콘
          _buildHomeIcon(),

          // 제목과 설명을 하나로 묶어서 간격 절약
          Column(
            children: [
              Text(
                '집 주소 설정하기 🏠',
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '집에서 출발하는 최적의 경로를\n안내해드릴게요',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          // 🆕 현재 설정된 주소 또는 입력 필드
          Obx(() => _buildAddressSection()),

          // 🆕 간단한 도움말
          _buildHelpMessage(),

          // 🆕 혜택 안내
          _buildBenefitMessage(),
        ],
      ),
    );
  }

  // 집 아이콘
  Widget _buildHomeIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green,
            Colors.green.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.home,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  // 🆕 주소 섹션 (설정된 주소 표시 또는 입력 필드)
  Widget _buildAddressSection() {
    if (controller.homeAddress.value.isNotEmpty) {
      return _buildSetAddress();
    } else {
      return _buildAddressInput();
    }
  }

  // 설정된 주소 표시
  Widget _buildSetAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '집 주소 설정 완료',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.homeAddress.value,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.green[800],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              controller.setHomeAddress('');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(
              '주소 변경',
              style: TextStyle(
                color: Colors.green[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 주소 입력 필드
  Widget _buildAddressInput() {
    final TextEditingController searchController = TextEditingController();
    final RxList<String> searchResults = <String>[].obs;
    final RxBool isSearching = false.obs;

    return Column(
      children: [
        // 주소 검색 입력 필드
        TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: '집 주소를 입력하세요',
            hintText: '예: 서울특별시 강남구',
            prefixIcon: Icon(
              Icons.search,
              color: Colors.green[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[600]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) async {
            if (value.length > 2) {
              isSearching.value = true;
              final results = await controller.searchAddress(value);
              searchResults.value = results.take(3).toList(); // 최대 3개만
              isSearching.value = false;
            } else {
              searchResults.clear();
            }
          },
        ),

        // 🆕 간단한 검색 결과 (최대 3개, 컴팩트)
        Obx(() => _buildCompactSearchResults(searchResults, isSearching)),
      ],
    );
  }

  // 🆕 컴팩트한 검색 결과
  Widget _buildCompactSearchResults(RxList<String> searchResults, RxBool isSearching) {
    if (isSearching.value) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        height: 40,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final address = searchResults[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.location_on,
              color: Colors.green[600],
              size: 16,
            ),
            title: Text(
              address,
              style: Get.textTheme.bodySmall?.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              controller.setHomeAddress(address);
              searchResults.clear();
            },
          );
        },
      ),
    );
  }

  // 🆕 간단한 도움말
  Widget _buildHelpMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '구체적인 주소일수록 더 정확한 경로를 안내받을 수 있어요',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 혜택 안내 메시지
  Widget _buildBenefitMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.route,
            size: 16,
            color: Colors.green[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '🚗 집에서 회사까지 최적 경로와 소요시간을 계산해드려요',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.green[700],
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