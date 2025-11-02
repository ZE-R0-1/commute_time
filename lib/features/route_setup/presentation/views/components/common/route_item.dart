import 'package:flutter/material.dart';

class RouteItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isEditMode;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showDelete;

  const RouteItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isEditMode = false,
    this.onEdit,
    this.onDelete,
    this.showDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // 수정 모드일 때 버튼들 표시
        if (isEditMode) ...[
          const SizedBox(width: 8),
          // 수정 버튼
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.edit,
                size: 16,
                color: iconColor,
              ),
            ),
          ),
          // 삭제 버튼 (환승지만)
          if (showDelete && onDelete != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete,
                  size: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}