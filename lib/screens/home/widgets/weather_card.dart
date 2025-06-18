import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class WeatherCard extends GetView<HomeController> {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '날씨',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Obx(() => controller.isLoadingWeather.value
              ? const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 온도
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.currentTemp.value}°',
                    style: Get.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.currentWeather.value,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          controller.currentLocation.value,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 날씨 아이콘
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getWeatherColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getWeatherIcon(),
                      color: _getWeatherColor(),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getWeatherDescription(),
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: _getWeatherColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon() {
    switch (controller.currentWeather.value) {
      case '맑음':
        return Icons.wb_sunny;
      case '흐림':
        return Icons.cloud;
      case '비':
        return Icons.umbrella;
      case '눈':
        return Icons.ac_unit;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getWeatherColor() {
    switch (controller.currentWeather.value) {
      case '맑음':
        return Colors.orange;
      case '흐림':
        return Colors.grey;
      case '비':
        return Colors.blue;
      case '눈':
        return Colors.lightBlue;
      default:
        return Colors.orange;
    }
  }

  String _getWeatherDescription() {
    final temp = controller.currentTemp.value;

    if (temp >= 25) {
      return '따뜻한 날씨입니다';
    } else if (temp >= 15) {
      return '쾌적한 날씨입니다';
    } else if (temp >= 5) {
      return '시원한 날씨입니다';
    } else {
      return '추운 날씨입니다';
    }
  }
}