import 'package:flutter/material.dart';

class RouteSetupProgress extends StatelessWidget {
  const RouteSetupProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '3단계 중 1단계 완료',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '33%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final gapWidth = 8.0;
        final totalGaps = gapWidth * 2; // 3단계이므로 간격은 2개
        final segmentWidth = (totalWidth - totalGaps) / 3; // 3개의 세그먼트

        return Row(
          children: [
            // 1단계 (완료)
            Container(
              width: segmentWidth,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(width: gapWidth),
            // 2-3단계 (미완료)
            ...List.generate(
                2,
                (index) => [
                      Container(
                        width: segmentWidth,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      if (index < 1) SizedBox(width: gapWidth),
                    ]).expand((x) => x),
          ],
        );
      },
    );
  }
}