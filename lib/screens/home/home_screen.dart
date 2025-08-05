import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // 커스텀 헤더
            _buildHeader(),
            
            // 메인 콘텐츠
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 홈 아이콘
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2196F3), // 파란색
                            Color(0xFF3F51B5), // 인디고색
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 제목
                    Text(
                      '출퇴근 알리미',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 설명
                    Text(
                      '스마트한 출퇴근 관리로\n더 편리한 일상을 만들어보세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // 곧 추가될 기능 안내
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.construction,
                            size: 48,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '개발 중인 기능',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '출퇴근 정보, 실시간 알림 등\n다양한 기능이 곧 추가될 예정입니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 인사말
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '오늘도 좋은 하루 되세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 알림 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // 알림 기능 (추후 구현)
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}