// lib/screens/onboarding/widgets/step_work_address.dart (미니멀 디자인)
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24), // 🆕 패딩 조정
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 🆕 중앙 정렬
          children: [
            const SizedBox(height: 40), // 🆕 상단 여백

            // 회사 아이콘 (그대로 유지)
            _buildWorkIcon(),

            const SizedBox(height: 40), // 🆕 여백 조정

            // 🆕 미니멀한 제목과 설명
            _buildMinimalTitle(),

            const SizedBox(height: 32), // 🆕 여백 조정

            // 현재 설정된 주소 또는 입력 필드
            Obx(() => _buildAddressSection(scrollController)),

            const SizedBox(height: 40), // 🆕 하단 여백
          ],
        ),
      ),
    );
  }

  // 회사 아이콘 (그대로 유지)
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

  // 🆕 미니멀한 제목과 설명
  Widget _buildMinimalTitle() {
    return Column(
      children: [
        Text(
          '회사 주소',
          style: Get.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.grey[800],
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '출퇴근 경로 최적화를 위해 설정해주세요',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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

  // 🆕 미니멀한 설정된 주소 표시
  Widget _buildSetAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange[100]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.orange[600],
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            controller.workAddress.value,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.orange[800],
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              controller.setWorkAddress('');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange[600],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              '변경하기',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 미니멀한 주소 입력 필드
  Widget _buildAddressInput(ScrollController scrollController) {
    final TextEditingController searchController = TextEditingController();
    final RxList<String> searchResults = <String>[].obs;
    final RxBool isSearching = false.obs;
    final FocusNode focusNode = FocusNode();

    Timer? debounceTimer;

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 350), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });

    void performSearch(String query) {
      debounceTimer?.cancel();

      if (query.length <= 1) {
        searchResults.clear();
        isSearching.value = false;
        return;
      }

      debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        if (query.length > 1) {
          isSearching.value = true;

          try {
            final results = await controller.searchAddress(query);

            if (searchController.text.trim() == query) {
              searchResults.value = results.take(6).toList(); // 🆕 6개로 조정
            }
          } catch (e) {
            print('회사 주소 검색 오류: $e');
          } finally {
            isSearching.value = false;
          }
        }
      });
    }

    return Column(
      children: [
        // 🆕 미니멀한 검색 입력 필드
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: searchController,
            focusNode: focusNode,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '회사명 또는 건물명 입력',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey[400],
                size: 22,
              ),
              suffixIcon: Obx(() => isSearching.value
                  ? Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orange[600],
                  ),
                ),
              )
                  : searchController.text.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  searchController.clear();
                  searchResults.clear();
                  debounceTimer?.cancel();
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
              )
                  : const SizedBox.shrink()),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.orange[300]!,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              performSearch(value.trim());
            },
          ),
        ),

        // 🆕 미니멀한 검색 결과 표시
        Obx(() => _buildMinimalSearchResults(
          searchResults,
          isSearching,
          searchController,
          debounceTimer,
        )),
      ],
    );
  }

  // 🆕 미니멀한 검색 결과 위젯
  Widget _buildMinimalSearchResults(
      RxList<String> searchResults,
      RxBool isSearching,
      TextEditingController searchController,
      Timer? debounceTimer,
      ) {
    if (searchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 12),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: searchResults.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey[100],
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final address = searchResults[index];
            return InkWell(
              onTap: () async {
                await controller.selectAddressFromSearch(
                  searchController.text.trim(),
                  address,
                  false, // isHome = false (회사 주소)
                );
                searchResults.clear();
                searchController.clear();
                debounceTimer?.cancel();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}