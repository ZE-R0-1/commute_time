import 'package:flutter/material.dart';

/// 검색 입력 필드 컴포넌트
class SearchInputField extends StatelessWidget {
  final VoidCallback onTap;

  const SearchInputField({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '주소, 건물명, 장소명을 입력하세요',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
