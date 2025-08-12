import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';
import '../../app/services/weather_service.dart';
import '../../app/services/subway_service.dart';

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
                onTap: controller.refreshAllArrivalInfo,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.blue[600],
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
                      _extractStationName(stationName),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color.shade800,
                      ),
                    ),
                    if (_extractDirectionInfo(stationName).isNotEmpty)
                      Text(
                        _extractDirectionInfo(stationName),
                        style: TextStyle(
                          fontSize: 12,
                          color: color.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              
              // 실시간 도착정보 (모든 역에 대해 표시)
              if (isFirst)
                Obx(() => _buildRealTimeArrivalInfo(color, 'departure'))
              else if (!isFirst && !isLast)
                // 환승지의 경우 인덱스 찾기
                Obx(() {
                  int transferIndex = -1;
                  for (int i = 0; i < controller.transferStations.length; i++) {
                    if (controller.transferStations[i]['name'] == stationName) {
                      transferIndex = i;
                      break;
                    }
                  }
                  return transferIndex >= 0 
                    ? _buildRealTimeArrivalInfo(color, 'transfer', transferIndex: transferIndex)
                    : const SizedBox.shrink();
                })
              else if (isLast)
                Obx(() => _buildRealTimeArrivalInfo(color, 'destination')),
            ],
          ),
        ),
      ],
    );
  }

  // 실시간 도착정보 위젯
  Widget _buildRealTimeArrivalInfo(MaterialColor color, String stationType, {int? transferIndex}) {
    // 로딩 상태 확인
    bool isLoading = false;
    String errorMessage = '';
    List<SubwayArrival> arrivalData = [];
    
    switch (stationType) {
      case 'departure':
        isLoading = controller.isLoadingArrival.value;
        errorMessage = controller.arrivalError.value;
        arrivalData = controller.departureArrivalInfo;
        break;
      case 'transfer':
        if (transferIndex != null && transferIndex < controller.transferArrivalInfo.length) {
          isLoading = controller.isLoadingTransferArrival.value;
          errorMessage = controller.transferArrivalError.value;
          arrivalData = controller.transferArrivalInfo[transferIndex];
        }
        break;
      case 'destination':
        isLoading = controller.isLoadingDestinationArrival.value;
        errorMessage = controller.destinationArrivalError.value;
        arrivalData = controller.destinationArrivalInfo;
        break;
    }

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          '정보없음',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    if (arrivalData.isEmpty) {
      return const SizedBox.shrink();
    }

    // 방향별로 그룹화 (바텀시트와 동일한 로직)
    final Map<String, List<SubwayArrival>> groupedByDirection = {};
    for (final arrival in arrivalData) {
      final key = '${arrival.lineDisplayName}_${arrival.cleanTrainLineNm}';
      if (!groupedByDirection.containsKey(key)) {
        groupedByDirection[key] = [];
      }
      groupedByDirection[key]!.add(arrival);
    }
    
    if (groupedByDirection.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedByDirection.entries.take(2).map((directionEntry) {
          final arrivals = directionEntry.value.take(2).toList();
          final firstArrival = arrivals.first;
          final secondArrival = arrivals.length > 1 ? arrivals[1] : null;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 호선 표시
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLineColor(firstArrival.subwayId),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        firstArrival.lineDisplayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // 방향 표시
                Text(
                  firstArrival.cleanTrainLineNm,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // 첫 번째 열차
                _buildArrivalTimeRow(firstArrival, true),
                
                // 두 번째 열차 (있을 때만)
                if (secondArrival != null) ...[
                  const SizedBox(height: 3),
                  _buildArrivalTimeRow(secondArrival, false),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 도착시간 행 위젯
  Widget _buildArrivalTimeRow(SubwayArrival arrival, bool isFirst) {
    Color statusColor = Colors.blue[600]!;
    if (arrival.arrivalTimeText.contains('진입') || arrival.arvlCd == 0) {
      statusColor = Colors.green[600]!;
    } else if (arrival.arrivalTimeText.contains('도착') || arrival.arvlCd == 5) {
      statusColor = Colors.red[600]!;
    }

    return Row(
      children: [
        // 상태 아이콘
        Text(
          arrival.arrivalStatusIcon,
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(width: 4),
        
        // 도착시간
        Expanded(
          child: Text(
            arrival.arrivalTimeText,
            style: TextStyle(
              fontSize: isFirst ? 11 : 10,
              fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
              color: statusColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // 열차번호 (공간이 있을 때만)
        if (arrival.btrainNo.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            arrival.btrainNo,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  // 호선 색상 가져오기 (바텀시트와 동일한 로직)
  Color _getLineColor(String subwayId) {
    switch (subwayId) {
      case '1001': return const Color(0xFF263C96); // 1호선
      case '1002': return const Color(0xFF00A84D); // 2호선  
      case '1003': return const Color(0xFFEF7C1C); // 3호선
      case '1004': return const Color(0xFF00A5DE); // 4호선
      case '1005': return const Color(0xFF996CAC); // 5호선
      case '1006': return const Color(0xFFCD7C2F); // 6호선
      case '1007': return const Color(0xFF747F00); // 7호선
      case '1008': return const Color(0xFFE6186C); // 8호선
      case '1009': return const Color(0xFFBB8336); // 9호선
      case '1063': return const Color(0xFF77C4A3); // 경의중앙선
      case '1065': return const Color(0xFF0090D2); // 공항철도
      case '1067': return const Color(0xFFF5A200); // 경춘선
      case '1075': return const Color(0xFF32C6A6); // 수인분당선
      case '1077': return const Color(0xFFB7CE63); // 신분당선
      case '1092': return const Color(0xFF6789CA); // 우이신설선
      default: return Colors.grey;
    }
  }

  // 역명에서 순수 역명 추출 (예: "강남역 2호선 (성수방면)" → "강남역")
  String _extractStationName(String fullStationName) {
    // 첫 번째 공백 이전의 역명만 추출 (역명은 보통 첫 번째 단어)
    final parts = fullStationName.split(' ');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return fullStationName;
  }

  // 방면 정보 추출 (예: "강남역 2호선 (성수방면)" → "2호선 (성수방면)")
  String _extractDirectionInfo(String fullStationName) {
    // 역명 제거 후 나머지 정보 반환
    final cleanStationName = _extractStationName(fullStationName);
    if (fullStationName.length > cleanStationName.length) {
      return fullStationName.substring(cleanStationName.length).trim();
    }
    return '';
  }

}