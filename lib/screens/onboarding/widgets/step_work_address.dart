import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboarding_controller.dart';

class StepWorkAddress extends GetView<OnboardingController> {
  const StepWorkAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 🆕 회사 아이콘
          _buildWorkIcon(),

          // 제목과 설명을 하나로 묶어서 간격 절약
          Column(
            children: [
              Text(
                '회사 주소 설정하기 🏢',
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '출퇴근 시간에 맞는 최적의 경로를\n미리 확인해보세요',
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

  // 회사 아이콘
  Widget _buildWorkIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange,
            Colors.orange.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.business,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  // 🆕 주소 섹션 (설정된 주소 표시 또는 입력 필드)
  Widget _buildAddressSection() {
    if (controller.workAddress.value.isNotEmpty) {
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
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '회사 주소 설정 완료',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.workAddress.value,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.orange[800],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              controller.setWorkAddress('');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(
              '주소 변경',
              style: TextStyle(
                color: Colors.orange[600],
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
            labelText: '회사 주소를 입력하세요',
            hintText: '예: 서울특별시 강남구 테헤란로',
            prefixIcon: Icon(
              Icons.search,
              color: Colors.orange[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange[600]!),
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
              color: Colors.orange[600],
              size: 16,
            ),
            title: Text(
              address,
              style: Get.textTheme.bodySmall?.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              controller.setWorkAddress(address);
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
              '회사명보다는 정확한 주소를 입력하시면 더 정확해요',
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
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: Colors.orange[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '⏰ 출근 시간에 맞춰 언제 출발해야 하는지 알려드려요',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.orange[700],
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