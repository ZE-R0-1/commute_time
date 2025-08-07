import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';
import '../../app/services/weather_service.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // 커스텀 헤더
            _buildHeader(),
            
            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // 날씨 카드
                    _buildWeatherCard(),
                    
                    const SizedBox(height: 24),
                    
                    // 비 예보 카드 (있을 때만)
                    Obx(() {
                      if (controller.rainForecast.value != null && 
                          controller.rainForecast.value!.willRain) {
                        return _buildRainForecastCard();
                      }
                      return const SizedBox.shrink();
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // 곧 추가될 기능 안내
                    _buildUpcomingFeaturesCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 인사말
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '오늘도 좋은 하루 되세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 알림 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // 알림 기능 (추후 구현)
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 날씨 카드 위젯
  Widget _buildWeatherCard() {
    return Obx(() {
      if (controller.isWeatherLoading.value) {
        return _buildWeatherLoadingCard();
      }
      
      if (controller.weatherError.value.isNotEmpty) {
        return _buildWeatherErrorCard();
      }
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4FC3F7), // 하늘색
              Color(0xFF29B6F6), // 진한 하늘색
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
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
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    controller.currentAddress.value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                InkWell(
                  onTap: controller.refreshWeather,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 현재 날씨 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 날씨 아이콘과 상태
                Row(
                  children: [
                    Text(
                      controller.getWeatherIcon(controller.currentWeather.value),
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.getWeatherStatusText(controller.currentWeather.value),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '습도 ${controller.currentWeather.value?.humidity ?? 0}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // 온도
                Text(
                  '${controller.currentWeather.value?.temperature.round() ?? '--'}°',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 구분선
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            
            const SizedBox(height: 12),
            
            // 다음 6시간 예보
            _buildHourlyForecast(),
          ],
        ),
      );
    });
  }

  // 시간별 날씨 예보
  Widget _buildHourlyForecast() {
    if (controller.weatherForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final next6Hours = controller.weatherForecast.where((forecast) =>
      forecast.dateTime.isAfter(now) &&
      forecast.dateTime.isBefore(now.add(const Duration(hours: 7)))
    ).take(6).toList();

    if (next6Hours.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '다음 ${next6Hours.length}시간 예보:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        // 시간 행
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: next6Hours.map((forecast) => 
            Expanded(
              child: Text(
                '${forecast.dateTime.hour}시',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ).toList(),
        ),
        
        const SizedBox(height: 4),
        
        // 온도 행
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: next6Hours.map((forecast) => 
            Expanded(
              child: Text(
                '${forecast.temperature.round()}°',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).toList(),
        ),
        
        const SizedBox(height: 6),
        
        // 날씨 아이콘 행
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: next6Hours.map((forecast) => 
            Expanded(
              child: Text(
                controller.getWeatherIconForForecast(forecast),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ).toList(),
        ),
        
        const SizedBox(height: 4),
        
        // 습도 행
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: next6Hours.map((forecast) => 
            Expanded(
              child: Text(
                '${forecast.humidity}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  // 날씨 로딩 카드
  Widget _buildWeatherLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF4FC3F7),
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
            controller.loadingMessage.value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          )),
        ],
      ),
    );
  }

  // 날씨 오류 카드
  Widget _buildWeatherErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            controller.weatherError.value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: controller.refreshWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                ),
                child: const Text('다시 시도'),
              ),
              if (controller.weatherError.value.contains('권한') || 
                  controller.weatherError.value.contains('위치'))
                const SizedBox(width: 8),
              if (controller.weatherError.value.contains('권한') || 
                  controller.weatherError.value.contains('위치'))
                ElevatedButton(
                  onPressed: () async {
                    // 앱 설정으로 이동
                    await controller.openAppSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('설정'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 비 예보 카드
  Widget _buildRainForecastCard() {
    final rainInfo = controller.rainForecast.value!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF64B5F6), // 연한 파란색
            Color(0xFF42A5F5), // 파란색
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64B5F6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              const Text(
                '🌧️',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '비 예보',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (rainInfo.intensity != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rainInfo.intensity == RainIntensity.heavy ? '강한 비' : '약한 비',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 메시지
          Text(
            rainInfo.message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 조언
          Text(
            rainInfo.advice,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // 곧 추가될 기능 카드
  Widget _buildUpcomingFeaturesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.construction,
            size: 48,
            color: Colors.orange[600],
          ),
          const SizedBox(height: 16),
          Text(
            '개발 중인 기능',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '출퇴근 정보, 실시간 교통 상황,\n맞춤형 알림 등 다양한 기능이 곧 추가될 예정입니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}