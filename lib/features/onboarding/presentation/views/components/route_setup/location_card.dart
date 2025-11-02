import 'package:flutter/material.dart';
import '../../../../../../core/models/location_info.dart';

/// 선택된 위치를 표시하는 카드 컴포넌트
class LocationCard extends StatelessWidget {
  final LocationInfo location;
  final Color color;
  final String label;
  final VoidCallback onDelete;

  const LocationCard({
    super.key,
    required this.location,
    required this.color,
    required this.label,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getLocationIcon(),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  '$label • ${_getLocationTypeText()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.close,
              color: color,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLocationIcon() {
    switch (location.type) {
      case 'subway':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'map':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  String _getLocationTypeText() {
    switch (location.type) {
      case 'subway':
        return '지하철';
      case 'bus':
        return '버스';
      case 'map':
        return '지도';
      default:
        return '위치';
    }
  }
}

/// 위치 선택 버튼 컴포넌트
class LocationAddButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? additionalInfo;

  const LocationAddButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              additionalInfo != null ? '$label ($additionalInfo)' : label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}