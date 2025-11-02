import 'package:flutter/material.dart';
import 'category_button.dart';

/// 카테고리 필터 섹션 컴포넌트
class CategoryFilterSection extends StatelessWidget {
  final int selectedCategory;
  final Function(int) onCategoryChanged;

  const CategoryFilterSection({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CategoryButton(
          title: '지하철역',
          index: 0,
          selectedIndex: selectedCategory,
          icon: Icons.train,
          color: Colors.blue,
          onTap: () => onCategoryChanged(0),
        ),
        const SizedBox(width: 8),
        CategoryButton(
          title: '버스정류장',
          index: 1,
          selectedIndex: selectedCategory,
          icon: Icons.directions_bus,
          color: Colors.green,
          onTap: () => onCategoryChanged(1),
        ),
      ],
    );
  }
}