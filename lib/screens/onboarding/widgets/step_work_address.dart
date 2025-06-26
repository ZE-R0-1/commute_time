// lib/screens/onboarding/widgets/step_work_address.dart (개선된 자동 검색)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboarding_controller.dart';

class StepWorkAddress extends GetView<OnboardingController> {
  const StepWorkAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 회사 아이콘
            _buildWorkIcon(),

            // 제목과 설명
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

            // 현재 설정된 주소 또는 입력 필드
            Obx(() => _buildAddressSection(scrollController)),

            // 간단한 도움말
            _buildHelpMessage(),

            // 혜택 안내
            _buildBenefitMessage(),
          ],
        ),
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

  // 주소 섹션
  Widget _buildAddressSection(ScrollController scrollController) {
    if (controller.workAddress.value.isNotEmpty) {
      return _buildSetAddress();
    } else {
      return _buildAddressInput(scrollController);
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

  // 🆕 개선된 실시간 검색 주소 입력 필드
  Widget _buildAddressInput(ScrollController scrollController) {
    final TextEditingController searchController = TextEditingController();
    final RxList<String> searchResults = <String>[].obs;
    final RxBool isSearching = false.obs;
    final FocusNode focusNode = FocusNode();

    // 🆕 디바운싱을 위한 타이머
    Timer? debounceTimer;

    // 🆕 포커스 처리
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent * 0.4,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });

    // 🆕 개선된 검색 함수 (디바운싱 적용)
    void performSearch(String query) {
      // 이전 타이머 취소
      debounceTimer?.cancel();

      // 1글자 이하면 결과만 지우고 검색 안함
      if (query.length <= 1) {
        searchResults.clear();
        isSearching.value = false;
        return;
      }

      // 🆕 500ms 후에 검색 실행 (디바운싱)
      debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        if (query.length > 1) {
          isSearching.value = true;

          try {
            final results = await controller.searchAddress(query);

            // 🆕 검색어가 여전히 같을 때만 결과 업데이트
            if (searchController.text.trim() == query) {
              searchResults.value = results.take(8).toList(); // 최대 8개로 증가
            }
          } catch (e) {
            print('회사 주소 검색 오류: $e');
            // 🆕 에러가 나도 기존 결과는 유지
          } finally {
            isSearching.value = false;
          }
        }
      });
    }

    return Column(
      children: [
        // 검색 입력 필드
        TextFormField(
          controller: searchController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: '회사 주소를 입력하세요',
            hintText: '예: 마포구 월드컵북로 또는 회사명',
            prefixIcon: Icon(
              Icons.search,
              color: Colors.orange[600],
            ),
            // 🆕 검색 중일 때만 로딩 표시 (작게)
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
          // 🆕 디바운싱 적용된 검색
          onChanged: (value) {
            performSearch(value.trim());
          },
        ),

        // 🆕 개선된 검색 결과 표시
        Obx(() => _buildSmoothSearchResults(
          searchResults,
          isSearching,
          searchController,
          debounceTimer,
        )),
      ],
    );
  }

  // 🆕 부드러운 검색 결과 위젯
  Widget _buildSmoothSearchResults(
      RxList<String> searchResults,
      RxBool isSearching,
      TextEditingController searchController,
      Timer? debounceTimer,
      ) {
    // 검색 결과가 없으면 표시 안함
    if (searchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // 🆕 부드러운 애니메이션
      margin: const EdgeInsets.only(top: 12),
      constraints: const BoxConstraints(maxHeight: 200), // 높이 약간 증가
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange[200]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🆕 검색 결과 헤더 (개선)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.orange[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '검색 결과 ${searchResults.length}개',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                const Spacer(),
                // 🆕 검색 중일 때 작은 로딩 표시
                if (isSearching.value) ...[
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                InkWell(
                  onTap: () {
                    searchResults.clear();
                    debounceTimer?.cancel();
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.orange[600],
                    size: 16,
                  ),
                ),
              ],
            ),
          ),

          // 검색 결과 리스트
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final address = searchResults[index];
                return InkWell(
                  onTap: () async {
                    // 상세 주소 정보와 함께 저장 (회사 주소)
                    await controller.selectAddressFromSearch(
                      searchController.text.trim(),
                      address,
                      false, // isHome = false (회사 주소)
                    );
                    searchResults.clear();
                    searchController.clear();
                    debounceTimer?.cancel();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: index < searchResults.length - 1
                          ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.orange[600],
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            address,
                            style: Get.textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 간단한 도움말
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
              '💡 2글자 이상 입력하면 자동으로 주소를 검색해요',
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

  // 혜택 안내 메시지
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