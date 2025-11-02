import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/subway_utils.dart';
import '../../../domain/usecases/get_subway_arrival_usecase.dart';
import '../../../domain/entities/subway_arrival_entity.dart';
import 'subway_arrival_card.dart';

class SubwayArrivalSheet {
  // 지하철 도착정보 바텀시트
  static void show({
    required String stationName,
    required VoidCallback onClose,
    required Function(String) onSelect,
    String mode = '',
    String placeName = '',
    String lineFilter = '',
  }) {
    final RxBool isLoading = true.obs;
    final RxList<SubwayArrivalEntity> arrivals = <SubwayArrivalEntity>[].obs;
    final RxString errorMessage = ''.obs;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 헤더
            _buildHeader(stationName, mode, onClose, onSelect, () async {
              isLoading.value = true;
              errorMessage.value = '';
              try {
                final usecase = Get.find<GetSubwayArrivalUseCase>();
                final result = await usecase(stationName);
                arrivals.value = _filterArrivals(result, lineFilter);
              } catch (e) {
                errorMessage.value = '도착정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.';
              } finally {
                isLoading.value = false;
              }
            }, placeName),

            // 내용
            Expanded(
              child: Obx(() => _buildContent(isLoading.value, arrivals, errorMessage.value, stationName, onSelect, onClose)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    ).then((_) => onClose());

    // 데이터 로드
    _loadArrivalInfo(stationName, isLoading, arrivals, errorMessage, lineFilter);
  }

  // 지하철 헤더 위젯
  static Widget _buildHeader(
    String stationName,
    String mode,
    VoidCallback onClose,
    Function(String) onSelect,
    VoidCallback onRefresh,
    String placeName,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.train, color: Colors.blue.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              placeName,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh, color: Colors.blue.shade600, size: 20),
            tooltip: '새로고침',
          ),
          IconButton(
            onPressed: () {
              Get.back();
              onClose();
            },
            icon: Icon(Icons.close, color: Colors.blue.shade600, size: 20),
          ),
        ],
      ),
    );
  }

  // 지하철 내용 위젯
  static Widget _buildContent(
    bool isLoading,
    RxList<SubwayArrivalEntity> arrivals,
    String errorMessage,
    String stationName,
    Function(String) onSelect,
    VoidCallback onClose,
  ) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (arrivals.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.train_outlined, color: Colors.grey.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              '현재 도착 정보가 없습니다',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 열차 종착지별로 그룹핑
    final Map<String, List<SubwayArrivalEntity>> groupedByDirection = {};
    for (final arrival in arrivals) {
      final key = '${arrival.lineDisplayName}_${arrival.cleanTrainLineNm}';
      if (!groupedByDirection.containsKey(key)) {
        groupedByDirection[key] = [];
      }
      groupedByDirection[key]!.add(arrival);
    }

    final groupedList = groupedByDirection.values.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groupedList.length,
      itemBuilder: (context, index) => SubwayArrivalCard(
        arrivals: groupedList[index],
        stationName: stationName,
        onSelect: onSelect,
        onClose: onClose,
      ),
    );
  }

  // 도착 정보 필터링 함수
  static List<SubwayArrivalEntity> _filterArrivals(List<SubwayArrivalEntity> arrivals, String lineFilter) {
    if (lineFilter.isEmpty) {
      return arrivals;
    }

    // lineFilter에서 노선명 추출 (예: "강남역 2호선" -> "2호선")
    String extractedLine = '';
    if (lineFilter.contains('1호선')) extractedLine = '1호선';
    else if (lineFilter.contains('2호선')) extractedLine = '2호선';
    else if (lineFilter.contains('3호선')) extractedLine = '3호선';
    else if (lineFilter.contains('4호선')) extractedLine = '4호선';
    else if (lineFilter.contains('5호선')) extractedLine = '5호선';
    else if (lineFilter.contains('6호선')) extractedLine = '6호선';
    else if (lineFilter.contains('7호선')) extractedLine = '7호선';
    else if (lineFilter.contains('8호선')) extractedLine = '8호선';
    else if (lineFilter.contains('9호선')) extractedLine = '9호선';
    else if (lineFilter.contains('신분당선')) extractedLine = '신분당선';
    else if (lineFilter.contains('분당선')) extractedLine = '분당선';
    else if (lineFilter.contains('경의중앙선')) extractedLine = '경의중앙선';
    else if (lineFilter.contains('공항철도')) extractedLine = '공항철도';
    else if (lineFilter.contains('경춘선')) extractedLine = '경춘선';
    else if (lineFilter.contains('수인분당선')) extractedLine = '수인분당선';
    else if (lineFilter.contains('우이신설선')) extractedLine = '우이신설선';
    else if (lineFilter.contains('서해선')) extractedLine = '서해선';
    else if (lineFilter.contains('김포골드라인')) extractedLine = '김포골드라인';
    else if (lineFilter.contains('신림선')) extractedLine = '신림선';

    if (extractedLine.isEmpty) {
      return arrivals;
    }

    print('🔍 필터링 적용: $lineFilter -> $extractedLine');

    final filtered = arrivals.where((arrival) {
      return arrival.lineDisplayName.contains(extractedLine) ||
             arrival.cleanTrainLineNm.contains(extractedLine);
    }).toList();

    print('📊 필터링 결과: ${arrivals.length}개 -> ${filtered.length}개');
    return filtered;
  }

  // 지하철 도착정보 로드
  static void _loadArrivalInfo(
    String stationName,
    RxBool isLoading,
    RxList<SubwayArrivalEntity> arrivals,
    RxString errorMessage,
    String lineFilter,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('🚇 지하철 도착정보 요청: $stationName');
      final usecase = Get.find<GetSubwayArrivalUseCase>();
      final result = await usecase(stationName);
      arrivals.value = _filterArrivals(result, lineFilter);

      print('✅ 지하철 도착정보 수신 완료: ${result.length}개');
      for (int i = 0; i < result.length; i++) {
        final arrival = result[i];
        print('  ${i + 1}. [${arrival.lineDisplayName}] ${arrival.cleanTrainLineNm} → ${arrival.directionText}');
        print('     도착시간: ${arrival.arrivalTimeText} ${arrival.arrivalStatusIcon}');
        print('     상태코드: ${arrival.arvlCd}');
      }
    } catch (e) {
      print('❌ 지하철 도착정보 로드 실패: $e');
      errorMessage.value = '도착정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.';
    } finally {
      isLoading.value = false;
    }
  }
}