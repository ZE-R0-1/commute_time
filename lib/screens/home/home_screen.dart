import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/services/weather_service.dart';
import '../../app/services/subway_service.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 🆕 고정된 상단 영역
          _buildFixedHeader(),

          // 🆕 스크롤 가능한 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 날씨 알림 카드
                    _buildWeatherCard(),

                    const SizedBox(height: 20),

                    // 🆕 메인 액션 카드 (시간대별 동적)
                    _buildMainActionCard(),

                    const SizedBox(height: 20),

                    // 🆕 조건부 출근/퇴근 카드
                    Obx(() {
                      final commuteType = controller.currentCommuteType.value;
                      if (commuteType == CommuteType.none) {
                        return const SizedBox.shrink();
                      }
                      return _buildConditionalCommuteCards();
                    }),

                    const SizedBox(height: 20),

                    // 🆕 실시간 지하철 정보
                    _buildSubwayInfoCard(),

                    const SizedBox(height: 20),

                    // 교통 상황
                    _buildTransportStatus(),

                    // 하단 여백
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 고정된 헤더 (스크롤되지 않음)
  Widget _buildFixedHeader() {
    return Container(
      width: double.infinity,
      color: Colors.grey[50], // 배경색과 동일
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽 제목
              const Text(
                '알출퇴',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              // 오른쪽 아이콘들 (새로고침 + 알림 순서)
              Row(
                children: [
                  // 새로고침 아이콘
                  Obx(() => IconButton(
                    onPressed: controller.isLoading.value ||
                        controller.isLocationLoading.value ||
                        controller.isWeatherLoading.value
                        ? null
                        : controller.refresh,
                    icon: controller.isLoading.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black87,
                      ),
                    )
                        : const Icon(
                      Icons.refresh,
                      color: Colors.black87,
                      size: 28,
                    ),
                    tooltip: '새로고침',
                  )),

                  // 알림 아이콘
                  IconButton(
                    onPressed: () {
                      // TODO: 알림 화면으로 이동
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.black87,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 날씨 알림 카드 (GPS 위치 기반)
  Widget _buildWeatherCard() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 제목만
          const Text(
            '🌤️ 오늘 날씨',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 시간대별 날씨 (로딩 중이거나 데이터가 없으면 로딩 표시)
          if (controller.isWeatherLoading.value || controller.isLocationLoading.value)
            _buildWeatherLoadingList()
          else if (controller.weatherForecast.isEmpty)
            _buildWeatherErrorState()
          else
            _buildHourlyWeatherList(),
        ],
      ),
    ));
  }

// 시간대별 날씨 리스트
  Widget _buildHourlyWeatherList() {
    final forecasts = _getFilteredHourlyForecasts();

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecasts.length,
        itemBuilder: (context, index) {
          final forecast = forecasts[index];
          final isNow = index == 0; // 첫 번째는 현재 시간

          return _buildHourlyWeatherItem(forecast, isNow);
        },
      ),
    );
  }

// 개별 시간대 날씨 아이템
  Widget _buildHourlyWeatherItem(WeatherForecast forecast, bool isNow) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isNow ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isNow ? Border.all(color: Colors.blue[200]!) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 시간
          Text(
            isNow ? '지금' : _formatHour(forecast.dateTime),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isNow ? FontWeight.w600 : FontWeight.normal,
              color: isNow ? Colors.blue[700] : Colors.grey[600],
            ),
          ),

          const SizedBox(height: 4),

          // 날씨 아이콘
          Icon(
            _getWeatherIconForForecast(forecast),
            size: 20,
            color: _getWeatherIconColor(forecast),
          ),

          const SizedBox(height: 4),

          // 온도
          Text(
            '${forecast.temperature.round()}°',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isNow ? Colors.blue[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

// 로딩 상태 리스트
  Widget _buildWeatherLoadingList() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6, // 6개 로딩 카드
        itemBuilder: (context, index) {
          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 20,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// 오류 상태
  Widget _buildWeatherErrorState() {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            '날씨 정보를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

// 현재 시간부터 시간대별 예보 필터링
  List<WeatherForecast> _getFilteredHourlyForecasts() {
    final forecasts = controller.weatherForecast;
    if (forecasts.isEmpty) return [];

    final now = DateTime.now();
    final currentHour = DateTime(now.year, now.month, now.day, now.hour);

    // 현재 시간부터 12시간 후까지 (또는 데이터가 있는 만큼)
    List<WeatherForecast> filtered = [];

    // 현재 시간 추가 (현재 날씨가 있으면 사용, 없으면 가장 가까운 예보)
    final currentWeather = controller.currentWeather.value;
    if (currentWeather != null) {
      // 현재 날씨를 WeatherForecast 형태로 변환
      final currentForecast = WeatherForecast(
        dateTime: now,
        temperature: currentWeather.temperature,
        humidity: currentWeather.humidity,
        precipitation: currentWeather.precipitation,
        skyCondition: currentWeather.skyCondition,
        precipitationType: currentWeather.precipitationType,
      );
      filtered.add(currentForecast);
    }

    // 다음 시간들 추가
    for (int i = 1; i <= 12; i++) {
      final targetTime = currentHour.add(Duration(hours: i));

      // 해당 시간의 예보 찾기
      final forecast = forecasts.where((f) =>
      f.dateTime.year == targetTime.year &&
          f.dateTime.month == targetTime.month &&
          f.dateTime.day == targetTime.day &&
          f.dateTime.hour == targetTime.hour
      ).firstOrNull;

      if (forecast != null) {
        filtered.add(forecast);
      } else if (i <= 6) {
        // 6시간 이내는 빈 데이터라도 표시 (더미 데이터)
        filtered.add(WeatherForecast(
          dateTime: targetTime,
          temperature: currentWeather?.temperature ?? 20,
          humidity: 50,
          precipitation: '0',
          skyCondition: SkyCondition.clear,
          precipitationType: PrecipitationType.none,
        ));
      }
    }

    return filtered.take(12).toList(); // 최대 12개 (현재 + 11시간)
  }

// 시간 포맷팅 (24시간 형식, 간단하게)
  String _formatHour(DateTime dateTime) {
    final hour = dateTime.hour;
    return '${hour}시';
  }

// 예보용 날씨 아이콘
  IconData _getWeatherIconForForecast(WeatherForecast forecast) {
    // 강수 타입 우선 확인
    switch (forecast.precipitationType) {
      case PrecipitationType.rain:
      case PrecipitationType.rainDrop:
        return Icons.grain; // 비
      case PrecipitationType.snow:
      case PrecipitationType.snowDrop:
        return Icons.ac_unit; // 눈
      case PrecipitationType.rainSnow:
      case PrecipitationType.rainSnowDrop:
        return Icons.cloudy_snowing; // 진눈깨비
      default:
        break;
    }

    // 하늘 상태에 따른 아이콘
    switch (forecast.skyCondition) {
      case SkyCondition.clear:
        return Icons.wb_sunny; // 맑음
      case SkyCondition.partlyCloudy:
        return Icons.wb_cloudy; // 구름많음
      case SkyCondition.cloudy:
        return Icons.cloud; // 흐림
    }
  }

// 날씨 아이콘 색상
  Color _getWeatherIconColor(WeatherForecast forecast) {
    // 강수가 있으면 파란색
    if (forecast.precipitationType != PrecipitationType.none) {
      switch (forecast.precipitationType) {
        case PrecipitationType.rain:
        case PrecipitationType.rainDrop:
        case PrecipitationType.rainSnow:
        case PrecipitationType.rainSnowDrop:
          return Colors.blue[600]!;
        case PrecipitationType.snow:
        case PrecipitationType.snowDrop:
          return Colors.lightBlue[400]!;
        default:
          break;
      }
    }

    // 하늘 상태에 따른 색상
    switch (forecast.skyCondition) {
      case SkyCondition.clear:
        return Colors.orange[600]!; // 맑음 - 주황
      case SkyCondition.partlyCloudy:
        return Colors.grey[600]!; // 구름많음 - 회색
      case SkyCondition.cloudy:
        return Colors.grey[700]!; // 흐림 - 진한 회색
    }
  }

  // 출근 정보 카드 (상세 버튼 추가)
  Widget _buildCommuteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 상세 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '🌅 오늘 출근',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // 상세 버튼 추가
              InkWell(
                onTap: controller.showCommuteRouteDetail,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '상세',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 권장 출발시간
          Obx(() => Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.recommendedDepartureTime.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )),

          const SizedBox(height: 16),

          // 경로 정보
          Obx(() => _buildInfoRow(
            Icons.route,
            '경로',
            controller.commuteRoute.value,
          )),

          const SizedBox(height: 12),

          // 소요시간
          Obx(() => _buildInfoRow(
            Icons.access_time,
            '예상 소요시간',
            controller.estimatedTime.value,
          )),

          const SizedBox(height: 12),

          // 교통비
          Obx(() => _buildInfoRow(
            Icons.payments,
            '교통비',
            controller.transportFee.value,
          )),
        ],
      ),
    );
  }

  // 퇴근 정보 카드 (상세 버튼 추가)
  Widget _buildReturnCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 상세 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.nights_stay,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '🌆 오늘 퇴근',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // 상세 버튼 추가
              InkWell(
                onTap: controller.showReturnRouteDetail,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '상세',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[600],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 권장 퇴근시간
          Obx(() => Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.recommendedOffTime.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )),

          const SizedBox(height: 16),

          // 일정 고려사항
          Obx(() => _buildInfoRow(
            Icons.event,
            '일정 고려',
            controller.eveningSchedule.value,
          )),

          const SizedBox(height: 12),

          // 여유시간
          Obx(() => _buildInfoRow(
            Icons.schedule,
            '여유 시간',
            controller.bufferTime.value,
          )),
        ],
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // 🆕 메인 액션 카드 (시간대별 동적)
  Widget _buildMainActionCard() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getMainActionGradient(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getMainActionColor().withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            controller.mainActionTitle.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 경로
          Row(
            children: [
              Icon(
                Icons.route,
                color: Colors.white.withValues(alpha: 0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                controller.mainActionRoute.value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 시간과 상세 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 소요시간
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.mainActionTime.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.mainActionDetail.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              
              // 실시간 탭 이동 버튼
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    // 실시간 탭으로 이동
                    final tabController = Get.find<dynamic>();
                    if (tabController.runtimeType.toString().contains('MainTabController')) {
                      tabController.changeTab(1); // 실시간 탭 인덱스
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _getMainActionColor(),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '실시간 정보',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // 🆕 조건부 출근/퇴근 카드
  Widget _buildConditionalCommuteCards() {
    final commuteType = controller.currentCommuteType.value;
    
    switch (commuteType) {
      case CommuteType.toWork:
        return _buildCommuteCard();
      case CommuteType.toHome:
        return _buildReturnCard();
      case CommuteType.none:
        return const SizedBox.shrink(); // 평상시에는 숨김
    }
  }

  // 🆕 메인 액션 카드 색상 결정
  Color _getMainActionColor() {
    switch (controller.currentCommuteType.value) {
      case CommuteType.toWork:
        return Colors.blue;
      case CommuteType.toHome:
        return Colors.green;
      case CommuteType.none:
        final hour = DateTime.now().hour;
        if (hour < 7 || hour > 20) return Colors.indigo;
        return Colors.teal;
    }
  }

  // 🆕 메인 액션 카드 그라데이션
  List<Color> _getMainActionGradient() {
    final baseColor = _getMainActionColor();
    return [
      baseColor,
      baseColor.withValues(alpha: 0.8),
    ];
  }

  // 🆕 실시간 지하철 정보 카드
  Widget _buildSubwayInfoCard() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.train,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🚇 지하철 실시간',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (controller.nearestStationName.value.isNotEmpty)
                        Text(
                          controller.nearestStationName.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              // 실시간 탭으로 이동 버튼
              InkWell(
                onTap: () {
                  final tabController = Get.find<dynamic>();
                  if (tabController.runtimeType.toString().contains('MainTabController')) {
                    tabController.changeTab(1); // 실시간 탭 인덱스
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '더보기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 지하철 도착 정보
          if (controller.isSubwayLoading.value)
            _buildSubwayLoadingState()
          else if (controller.nearestSubwayArrivals.isEmpty)
            _buildSubwayEmptyState()
          else
            _buildSubwayArrivalList(),
        ],
      ),
    ));
  }

  // 지하철 도착 정보 리스트
  Widget _buildSubwayArrivalList() {
    return Column(
      children: controller.nearestSubwayArrivals.take(3).map((arrival) => 
        _buildSubwayArrivalItem(arrival)
      ).toList(),
    );
  }

  // 개별 지하철 도착 정보
  Widget _buildSubwayArrivalItem(SubwayArrival arrival) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // 노선 색상
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getLineColor(arrival.subwayId),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 도착 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${(arrival.subwayId)} ${arrival.cleanTrainLineNm}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      arrival.arvlMsg2.isNotEmpty ? arrival.arvlMsg2 : arrival.arvlMsg3,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  arrival.arvlMsg3.isNotEmpty ? arrival.arvlMsg3 : '정보 없음',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 지하철 로딩 상태
  Widget _buildSubwayLoadingState() {
    return Column(
      children: List.generate(2, (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  // 지하철 정보 없음 상태
  Widget _buildSubwayEmptyState() {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.train_outlined,
            color: Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            '근처 지하철 정보를 찾을 수 없습니다',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 지하철 노선별 색상
  Color _getLineColor(String subwayId) {
    switch (subwayId) {
      case '1001': return const Color(0xFF0052A4); // 1호선
      case '1002': return const Color(0xFF00A84D); // 2호선
      case '1003': return const Color(0xFFEF7C1C); // 3호선
      case '1004': return const Color(0xFF00A5DE); // 4호선
      case '1005': return const Color(0xFF996CAC); // 5호선
      case '1006': return const Color(0xFFCD7C2F); // 6호선
      case '1007': return const Color(0xFF747F00); // 7호선
      case '1008': return const Color(0xFFE6186C); // 8호선
      case '1009': return const Color(0xFFBB8336); // 9호선
      default: return Colors.grey;
    }
  }

  // 교통 상황
  Widget _buildTransportStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚇 교통 상황',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: controller.transportStatus.length,
          itemBuilder: (context, index) {
            final transport = controller.transportStatus[index];
            return _buildTransportStatusCard(transport);
          },
        )),
      ],
    );
  }

  // 교통 상황 카드
  Widget _buildTransportStatusCard(TransportStatus transport) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: transport.color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: transport.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transport.icon,
              color: transport.color,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          // 교통수단명
          Text(
            transport.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // 상태
          Text(
            transport.statusText,
            style: TextStyle(
              fontSize: 12,
              color: transport.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}