import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

class SearchResultController extends GetxController {
  final TextEditingController textController = TextEditingController();
  
  // 검색어
  final RxString searchQuery = ''.obs;
  
  // 항상 전체 검색 (카테고리 필터 제거)
  final int selectedCategory = 2;
  
  // 검색 결과
  final RxList<SearchResultItem> searchResults = <SearchResultItem>[].obs;
  
  // 로딩 상태
  final RxBool isLoading = false.obs;
  
  // 최근 검색어
  final RxList<String> recentSearches = <String>[].obs;
  
  // 디바운스 타이머
  Timer? _searchDebounceTimer;
  
  // 스토리지
  final box = GetStorage();
  
  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }
  
  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    super.onClose();
  }
  
  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    textController.dispose();
    super.dispose();
  }
  
  void _loadRecentSearches() {
    final saved = box.read<List>('recent_searches') ?? [];
    recentSearches.value = saved.cast<String>();
  }
  
  void _saveRecentSearches() {
    box.write('recent_searches', recentSearches.toList());
  }
  
  void performSearch(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    
    isLoading.value = true;
    
    // 디바운스 타이머 설정
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(query);
    });
  }
  
  Future<void> _executeSearch(String query) async {
    try {
      final apiKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        print('❌ 카카오 REST API 키가 없습니다.');
        searchResults.clear();
        isLoading.value = false;
        return;
      }
      
      print('🔍 검색 실행: "$query"');
      
      // 키워드 검색 실행 (전체 검색)
      await _performKeywordSearch(query, apiKey);
      
    } catch (e, stackTrace) {
      print('❌ 검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _performKeywordSearch(String query, String apiKey) async {
    try {
      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/keyword.json'
        '?query=${Uri.encodeComponent(query)}'
        '&page=1'
        '&size=15'
      );
      
      print('🔍 키워드 검색 API 요청: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List;
        
        print('✅ 키워드 검색 완료! 총 ${documents.length}개의 결과');
        
        List<SearchResultItem> results = [];
        for (final doc in documents) {
          final item = SearchResultItem(
            id: doc['id'] ?? '',
            title: doc['place_name'] ?? '',
            subtitle: _formatCategoryName(doc['category_name'] ?? ''),
            address: doc['address_name'] ?? '',
            roadAddress: doc['road_address_name'] ?? '',
            latitude: double.tryParse(doc['y'].toString()) ?? 0.0,
            longitude: double.tryParse(doc['x'].toString()) ?? 0.0,
            distance: int.tryParse(doc['distance']?.toString() ?? '0'),
            category: _determineCategoryFromKakao(doc['category_name'] ?? ''),
            phone: doc['phone'] ?? '',
            placeUrl: doc['place_url'] ?? '',
          );
          
          // 모든 결과 포함 (카테고리 필터 제거)
          results.add(item);
        }
        
        searchResults.value = results;
        
      } else {
        print('❌ 키워드 검색 API 호출 실패: ${response.statusCode}');
        searchResults.clear();
      }
      
    } catch (e) {
      print('❌ 키워드 검색 중 오류: $e');
      searchResults.clear();
    }
  }
  
  String _determineCategoryFromKakao(String categoryName) {
    if (categoryName.contains('지하철') || categoryName.contains('역')) {
      return 'subway';
    } else if (categoryName.contains('버스') || categoryName.contains('정류장')) {
      return 'bus';
    }
    return 'place';
  }
  
  String _formatCategoryName(String categoryName) {
    if (categoryName.isEmpty) return '';
    
    final parts = categoryName.split(' > ');
    if (parts.length > 1) {
      return parts.last; // 마지막 카테고리만 표시
    }
    return categoryName;
  }
  
  void clearSearch() {
    textController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }
  
  void selectResult(SearchResultItem result) {
    // 최근 검색어에 추가
    _addToRecentSearches(result.title);
    
    // 결과를 이전 화면으로 전달
    Get.back(result: {
      'id': result.id,
      'title': result.title,
      'subtitle': result.subtitle,
      'address': result.address,
      'roadAddress': result.roadAddress,
      'latitude': result.latitude,
      'longitude': result.longitude,
      'category': result.category,
      'phone': result.phone,
      'placeUrl': result.placeUrl,
    });
  }
  
  void _addToRecentSearches(String search) {
    // 중복 제거
    recentSearches.remove(search);
    // 맨 앞에 추가
    recentSearches.insert(0, search);
    // 최대 10개까지만 유지
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
    _saveRecentSearches();
  }
  
  void selectRecentSearch(String search) {
    textController.text = search;
    performSearch(search);
  }
  
  void removeRecentSearch(String search) {
    recentSearches.remove(search);
    _saveRecentSearches();
  }
  
  void clearRecentSearches() {
    recentSearches.clear();
    _saveRecentSearches();
  }
}

class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String address;
  final String roadAddress;
  final double latitude;
  final double longitude;
  final int? distance;
  final String category;
  final String phone;
  final String placeUrl;
  
  SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.address,
    required this.roadAddress,
    required this.latitude,
    required this.longitude,
    this.distance,
    required this.category,
    required this.phone,
    required this.placeUrl,
  });
  
  @override
  String toString() {
    return 'SearchResultItem(id: $id, title: $title, category: $category, lat: $latitude, lng: $longitude)';
  }
}