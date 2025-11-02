import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/weather_controller.dart';
import 'weather_error_card.dart';
import 'weather_forecast_list.dart';
import 'weather_loading_card.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final weatherCtrl = Get.find<WeatherController>();

      // 로딩 중
      if (weatherCtrl.isWeatherLoading.value) {
        return const WeatherLoadingCard();
      }

      // 오류 발생
      if (weatherCtrl.weatherError.value.isNotEmpty) {
        return WeatherErrorCard(
          errorMessage: weatherCtrl.weatherError.value,
        );
      }

      // 정상 상태
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 헤더 (위치 정보와 새로고침)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Seoul, South Korea',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 시간별 날씨 예보
            const WeatherForecastList(),
          ],
        ),
      );
    });
  }
}