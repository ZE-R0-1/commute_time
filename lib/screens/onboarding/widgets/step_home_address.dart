import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboarding_controller.dart';

class StepHomeAddress extends GetView<OnboardingController> {
  const StepHomeAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // 집 아이콘
          Container(
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
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.home,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // 제목
          Text(
            controller.currentStepTitle,
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // 설명
          Text(
            controller.currentStepDescription,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // 주소 검색 입력
          _buildAddressSearch(),

          const SizedBox(height: 20),

          // 주소 결과 표시
          _buildAddressResults(),

          // 하단 여백 (키보드 올라올 때 대비)
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildAddressSearch() {
    final TextEditingController searchController = TextEditingController();
    final RxList<String> searchResults = <String>[].obs;
    final RxBool isSearching = false.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 현재 설정된 주소 표시
        Obx(() => controller.homeAddress.value.isNotEmpty
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.homeAddress.value,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  controller.setHomeAddress('');
                  searchController.clear();
                  searchResults.clear();
                },
                child: Text(
                  '변경',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        )
            : const SizedBox.shrink()
        ),

        // 주소 검색 입력 필드
        if (controller.homeAddress.value.isEmpty)
          TextFormField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: '집 주소 검색',
              hintText: '예: 서울특별시 강남구 테헤란로',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => isSearching.value
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : const SizedBox.shrink()
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Get.theme.primaryColor),
              ),
            ),
            onChanged: (value) async {
              if (value.length > 2) {
                isSearching.value = true;
                final results = await controller.searchAddress(value);
                searchResults.value = results;
                isSearching.value = false;
              } else {
                searchResults.clear();
              }
            },
          ),

        // 검색 결과를 여기에 표시
        if (controller.homeAddress.value.isEmpty)
          Obx(() => _buildSearchResults(searchResults, isSearching)),
      ],
    );
  }

  Widget _buildSearchResults(RxList<String> searchResults, RxBool isSearching) {
    if (isSearching.value) {
      return Container(
        height: 100,
        margin: const EdgeInsets.only(top: 12),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 300, // 최대 높이 제한
        minHeight: 50,
      ),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        shrinkWrap: true, // 내용에 맞춰 높이 조절
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final address = searchResults[index];
          return ListTile(
            leading: Icon(
              Icons.location_on,
              color: Get.theme.primaryColor,
              size: 20,
            ),
            title: Text(
              address,
              style: Get.textTheme.bodyMedium,
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

  Widget _buildAddressResults() {
    return Obx(() {
      if (controller.homeAddress.value.isNotEmpty) {
        return _buildAddressPreview();
      } else {
        return _buildEmptyState();
      }
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '주소를 검색해보세요',
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '예: 서울특별시, 강남구, 테헤란로',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.map,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '지도 미리보기',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '실제 서비스에서는 설정한 주소의\n지도를 미리 볼 수 있습니다.',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}