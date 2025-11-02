import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../home/domain/entities/location_permission_entity.dart';

Future<void> showLocationPermissionDialog(
  LocationPermissionEntity result, {
  required VoidCallback onRetry,
}) async {
  return Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Get.theme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('위치 권한 필요'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.message),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '위치 권한이 필요한 이유:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('• 현재 위치 날씨 정보 제공'),
                const Text('• 출퇴근 경로 최적화'),
                const Text('• 실시간 교통 상황 안내'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('나중에'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            onRetry();
          },
          child: const Text('권한 허용'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}