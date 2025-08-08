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
                    
                    // 경로 카드 (경로 데이터가 있을 때만)
                    Obx(() {
                      if (controller.hasRouteData.value) {
                        return Column(
                          children: [
                            _buildRouteCard(),
                            const SizedBox(height: 24),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    
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
                    controller.currentAddress.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
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
                      color: Colors.grey[600],
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 한 줄 스크롤 날씨 예보
            _buildHorizontalWeatherForecast(),
          ],
        ),
      );
    });
  }

  // 한 줄 날씨 예보 (횡스크롤)
  Widget _buildHorizontalWeatherForecast() {
    if (controller.weatherForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    
    // 현재 시간과 향후 예보 데이터 가져오기
    final currentForecast = controller.weatherForecast
        .where((f) => f.dateTime.hour == now.hour && 
                     f.dateTime.day == now.day)
        .firstOrNull;
    
    final futureForecasts = controller.weatherForecast
        .where((forecast) => forecast.dateTime.isAfter(now))
        .take(20) // 최대 20개 예보 표시
        .toList();

    List<WeatherForecast> allForecasts = [];
    if (currentForecast != null) {
      allForecasts.add(currentForecast);
    }
    allForecasts.addAll(futureForecasts);

    if (allForecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allForecasts.length,
        itemBuilder: (context, index) {
          final forecast = allForecasts[index];
          final isCurrentHour = index == 0 && currentForecast != null;
          
          return Container(
            width: 52,
            margin: const EdgeInsets.only(right: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 시간 표시
                Text(
                  isCurrentHour ? '현재' : '${forecast.dateTime.hour}시',
                  style: TextStyle(
                    fontSize: 11,
                    color: isCurrentHour ? Colors.blue[700] : Colors.grey[600],
                    fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                // 날씨 아이콘
                Text(
                  controller.getWeatherIconForForecast(forecast),
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 4),

                // 온도
                Text(
                  '${forecast.temperature.round()}°',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCurrentHour ? Colors.blue[700] : Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                // 습도
                Text(
                  '${forecast.humidity}%',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
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

  // 경로 카드 위젯
  Widget _buildRouteCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (경로 제목과 설정 버튼)
          Row(
            children: [
              Icon(
                Icons.route,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => Text(
                  controller.routeName.value.isEmpty ? '경로' : controller.routeName.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                )),
              ),
              InkWell(
                onTap: controller.goToRouteSettings,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.settings,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 출발지 정보
          Obx(() => _buildStationCard(
            controller.departureStation.value,
            '출발지',
            Icons.train,
            Colors.blue,
            isFirst: true,
          )),
          
          // 환승지들 (있을 때만)
          Obx(() {
            if (controller.transferStations.isNotEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  ...controller.transferStations.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> transfer = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildStationCard(
                        transfer['name'] ?? '',
                        '환승지 ${index + 1}',
                        Icons.swap_horiz,
                        Colors.orange,
                      ),
                    );
                  }),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          
          const SizedBox(height: 8),
          
          // 도착지 정보
          Obx(() => _buildStationCard(
            controller.arrivalStation.value,
            '도착지',
            Icons.location_on,
            Colors.green,
            isLast: true,
          )),
        ],
      ),
    );
  }

  // 역 정보 카드 (바텀시트 스타일 적용)
  Widget _buildStationCard(
    String stationName, 
    String label, 
    IconData icon, 
    MaterialColor color,
    {bool isFirst = false, bool isLast = false}
  ) {
    if (stationName.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // 역 정보
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.shade200),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stationName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 실시간 도착정보 (출발지일 때만 - 임시로 더미 데이터)
              if (isFirst)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '2분 후',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '5분 후',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
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