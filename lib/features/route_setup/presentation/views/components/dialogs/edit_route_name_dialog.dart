import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 경로 이름 변경 다이얼로그
///
/// 사용 예:
/// ```dart
/// final newName = await showEditRouteNameDialog(
///   context: context,
///   currentName: '기존 경로명',
/// );
/// ```
Future<String?> showEditRouteNameDialog({
  required BuildContext context,
  required String currentName,
}) async {
  final TextEditingController textController = TextEditingController(text: currentName);

  final newName = await Get.dialog<String?>(
    AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: const Text(
              '경로 이름 변경',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close,
              size: 20,
              color: Colors.grey,
            ),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '새로운 경로 이름을 입력해주세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '예: 집 → 회사, 출근길 등',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            onSubmitted: (value) {
              Get.back(result: value.trim().isNotEmpty ? value.trim() : null);
            },
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final newName = textController.text.trim();
            Get.back(result: newName.isNotEmpty ? newName : null);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 44),
          ),
          child: const Text('변경'),
        ),
      ],
    ),
    barrierDismissible: true,
  );

  return newName;
}