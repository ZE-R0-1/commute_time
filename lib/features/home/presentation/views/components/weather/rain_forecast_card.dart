import 'package:flutter/material.dart';

class RainForecastCard extends StatelessWidget {
  final String? intensity;
  final String? message;
  final String? advice;

  const RainForecastCard({
    super.key,
    this.intensity,
    this.message,
    this.advice,
  });

  @override
  Widget build(BuildContext context) {
    final displayIntensity = intensity ?? 'light';
    final displayMessage = message ?? '2시간 뒤 비가 내릴 예정입니다.';
    final displayAdvice = advice ?? '외출할 계획이 있다면 우산을 챙기세요.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF64B5F6),
            Color(0xFF42A5F5),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayIntensity == 'heavy' ? '강한 비' : '약한 비',
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

          Text(
            displayMessage,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            displayAdvice,
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
}