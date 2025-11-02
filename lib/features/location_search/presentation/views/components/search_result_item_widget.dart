import 'package:flutter/material.dart';
import '../../controllers/search_result_controller.dart';

/// 검색 결과 아이템 위젯 컴포넌트
class SearchResultItemWidget extends StatelessWidget {
  final SearchResultItem result;
  final VoidCallback onTap;

  const SearchResultItemWidget({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getIconColor(result.category).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIconData(result.category),
          size: 20,
          color: _getIconColor(result.category),
        ),
      ),
      title: Text(
        result.title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.subtitle.isNotEmpty)
            Text(
              result.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (result.address.isNotEmpty)
            Text(
              result.address,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (result.distance != null)
            Text(
              '${result.distance}m',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

  IconData _getIconData(String category) {
    switch (category) {
      case 'subway':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.place;
    }
  }

  Color _getIconColor(String category) {
    switch (category) {
      case 'subway':
        return Colors.blue;
      case 'bus':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}