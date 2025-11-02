import 'package:flutter/material.dart';

class WeatherForecastList extends StatelessWidget {
  const WeatherForecastList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        itemBuilder: (context, index) {
          return Container(
            width: 52,
            margin: const EdgeInsets.only(right: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  index == 0 ? '현재' : '${12 + index}시',
                  style: TextStyle(
                    fontSize: 11,
                    color: index == 0 ? Colors.blue[700] : Colors.grey[600],
                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '⛅',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  '${18 + index}°',
                  style: TextStyle(
                    fontSize: 12,
                    color: index == 0 ? Colors.blue[700] : Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${60 - index}%',
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
}