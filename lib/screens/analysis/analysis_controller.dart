import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalysisController extends GetxController {

  // 핵심 지표
  final RxString savedTime = '2시간 30분'.obs;

  // 평균 시간
  final RxString avgCommuteTime = '52분'.obs;
  final RxString avgReturnTime = '48분'.obs;

  // 교통비 분석
  final RxInt totalTransportCost = 54800.obs;
  final RxInt dailyAvgCost = 2740.obs;
  final RxInt expectedSaving = 3200.obs;

  // 요일별 패턴 데이터
  final RxList<WeeklyPatternData> weeklyPattern = <WeeklyPatternData>[].obs;

  // 월별 통계 데이터
  final RxList<MonthlyStatsData> monthlyStats = <MonthlyStatsData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAnalysisData();
  }

  // 분석 데이터 로드
  void _loadAnalysisData() {
    print('=== 분석 데이터 로딩 ===');

    _loadWeeklyPattern();
    _loadMonthlyStats();

    print('절약한 시간: ${savedTime.value}');
    print('평균 출근시간: ${avgCommuteTime.value}');
    print('평균 퇴근시간: ${avgReturnTime.value}');
    print('총 교통비: ${totalTransportCost.value}원');
  }

  // 요일별 패턴 데이터 로드
  void _loadWeeklyPattern() {
    weeklyPattern.value = [
      WeeklyPatternData(
        day: '월',
        commuteTime: 55,
        returnTime: 50,
        satisfaction: 3.5,
      ),
      WeeklyPatternData(
        day: '화',
        commuteTime: 48,
        returnTime: 45,
        satisfaction: 4.2,
      ),
      WeeklyPatternData(
        day: '수',
        commuteTime: 52,
        returnTime: 48,
        satisfaction: 4.0,
      ),
      WeeklyPatternData(
        day: '목',
        commuteTime: 58,
        returnTime: 52,
        satisfaction: 3.3,
      ),
      WeeklyPatternData(
        day: '금',
        commuteTime: 62,
        returnTime: 55,
        satisfaction: 2.8,
      ),
    ];
  }

  // 월별 통계 데이터 로드
  void _loadMonthlyStats() {
    monthlyStats.value = [
      MonthlyStatsData(month: '10월', totalTime: 180, cost: 52000),
      MonthlyStatsData(month: '11월', totalTime: 165, cost: 51600),
      MonthlyStatsData(month: '12월', totalTime: 150, cost: 54800),
    ];
  }

  // 데이터 새로고침
  Future<void> refreshAnalysis() async {
    print('분석 데이터 새로고침');

    // Mock: API 호출 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));

    // 새로운 데이터로 업데이트
    savedTime.value = '2시간 35분';
    avgCommuteTime.value = '51분';
    avgReturnTime.value = '47분';
    totalTransportCost.value = 55200;
    dailyAvgCost.value = 2760;
    expectedSaving.value = 3400;

    _loadWeeklyPattern();
    _loadMonthlyStats();
  }

  // 통계 계산 메서드들
  double get avgSatisfaction {
    if (weeklyPattern.isEmpty) return 0.0;
    final total = weeklyPattern.fold<double>(
      0.0,
          (sum, item) => sum + item.satisfaction,
    );
    return total / weeklyPattern.length;
  }

  int get totalCommuteMinutes {
    return weeklyPattern.fold<int>(
      0,
          (sum, item) => sum + item.commuteTime,
    );
  }

  int get totalReturnMinutes {
    return weeklyPattern.fold<int>(
      0,
          (sum, item) => sum + item.returnTime,
    );
  }

  // 요일별 최적/최악 시간 찾기
  WeeklyPatternData? get bestCommuteDay {
    if (weeklyPattern.isEmpty) return null;
    return weeklyPattern.reduce(
          (a, b) => a.commuteTime < b.commuteTime ? a : b,
    );
  }

  WeeklyPatternData? get worstCommuteDay {
    if (weeklyPattern.isEmpty) return null;
    return weeklyPattern.reduce(
          (a, b) => a.commuteTime > b.commuteTime ? a : b,
    );
  }

  // 교통비 절약률 계산
  double get savingPercentage {
    const baselineCost = 58000; // 기준 교통비
    final currentCost = totalTransportCost.value;
    return ((baselineCost - currentCost) / baselineCost * 100);
  }

  // 색상 헬퍼 메서드들
  Color getTimeColor(int minutes) {
    if (minutes <= 45) return Colors.green;
    if (minutes <= 55) return Colors.orange;
    return Colors.red;
  }

  Color getSatisfactionColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  // 포맷팅 메서드들
  String formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}원';
  }

  String formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}시간 ${mins}분';
    }
    return '${mins}분';
  }

  String formatSatisfaction(double rating) {
    return rating.toStringAsFixed(1);
  }
}

// 요일별 패턴 데이터 모델
class WeeklyPatternData {
  final String day;
  final int commuteTime; // 분 단위
  final int returnTime; // 분 단위
  final double satisfaction; // 1-5 점수

  WeeklyPatternData({
    required this.day,
    required this.commuteTime,
    required this.returnTime,
    required this.satisfaction,
  });
}

// 월별 통계 데이터 모델
class MonthlyStatsData {
  final String month;
  final int totalTime; // 분 단위
  final int cost; // 원 단위

  MonthlyStatsData({
    required this.month,
    required this.totalTime,
    required this.cost,
  });
}