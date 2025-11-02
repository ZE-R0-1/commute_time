import 'package:flutter/material.dart';

class AddTransferButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddTransferButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF97316).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFF97316).withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 18,
              color: Color(0xFFF97316),
            ),
            SizedBox(width: 8),
            Text(
              '환승지 추가',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ),
    );
  }
}