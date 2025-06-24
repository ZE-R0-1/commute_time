import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/services/weather_service.dart';
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

                    // 출근 정보 카드
                    _buildCommuteCard(),

                    const SizedBox(height: 16),

                    // 퇴근 정보 카드
                    _buildReturnCard(),

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
        color: controller.isLocationLoading.value || controller.isWeatherLoading.value
            ? Colors.grey[100]
            : Colors.yellow[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.isLocationLoading.value || controller.isWeatherLoading.value
              ? Colors.grey[200]!
              : Colors.yellow[200]!,
          width: 1,
        ),
      ),
      child: controller.isLocationLoading.value
          ? _buildLocationLoadingState()
          : controller.isWeatherLoading.value
          ? _buildWeatherLoadingState()
          : _buildWeatherContent(),
    ));
  }

  // 위치 조회 로딩 상태
  Widget _buildLocationLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '📍 현재 위치 조회 중...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'GPS를 이용해 정확한 위치를 확인하고 있습니다',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // 날씨 로딩 상태
  Widget _buildWeatherLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '날씨 정보 로딩 중...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '잠시만 기다려주세요',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // 날씨 정보 콘텐츠
  Widget _buildWeatherContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getWeatherIcon(),
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.weatherInfo.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          controller.weatherAdvice.value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),

        // 상세 날씨 정보 (현재 날씨가 있을 때만 표시)
        Obx(() {
          final weather = controller.currentWeather.value;
          if (weather != null) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherDetail('습도', '${weather.humidity}%'),
                      _buildWeatherDetail('풍속', '${weather.windSpeed.toStringAsFixed(1)}m/s'),
                      _buildWeatherDetail('강수량', weather.precipitation),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // 날씨 상세 정보 위젯
  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // 날씨에 따른 아이콘 선택
  IconData _getWeatherIcon() {
    final weather = controller.currentWeather.value;
    if (weather == null) return Icons.wb_cloudy;

    // 강수 타입 우선 확인
    switch (weather.precipitationType) {
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
    switch (weather.skyCondition) {
      case SkyCondition.clear:
        return Icons.wb_sunny; // 맑음
      case SkyCondition.partlyCloudy:
        return Icons.wb_cloudy; // 구름많음
      case SkyCondition.cloudy:
        return Icons.wb_cloudy; // 흐림
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