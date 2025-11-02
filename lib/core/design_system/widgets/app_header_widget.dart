import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 헤더 위젯
/// Home, Settings 등에서 재사용 가능하도록 설계됨
class AppHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final String? actionTooltip;

  const AppHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionIcon,
    this.onActionPressed,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 제목과 부제목
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 액션 버튼
          if (actionIcon != null)
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
                onPressed: onActionPressed,
                icon: Icon(
                  actionIcon,
                  color: Colors.grey[600],
                  size: 24,
                ),
                tooltip: actionTooltip,
              ),
            ),
        ],
      ),
    );
  }
}