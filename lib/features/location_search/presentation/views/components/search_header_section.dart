import 'package:flutter/material.dart';
import 'search_input_field.dart';
import 'category_filter_section.dart';

/// 검색 헤더 섹션 (검색창 + 카테고리 필터)
class SearchHeaderSection extends StatelessWidget {
  final VoidCallback onSearchTap;
  final int selectedCategory;
  final Function(int) onCategoryChanged;

  const SearchHeaderSection({
    super.key,
    required this.onSearchTap,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchInputField(onTap: onSearchTap),
        const SizedBox(height: 12),
        CategoryFilterSection(
          selectedCategory: selectedCategory,
          onCategoryChanged: onCategoryChanged,
        ),
      ],
    );
  }
}