import 'dart:convert';

import 'package:fmecg_mobile/constants/api_constant.dart';
import 'package:fmecg_mobile/providers/news_provider.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

NewsProvider newsProvider = Utils.globalContext!.read<NewsProvider>();

class NewsController {
  static String apiGetAllNews = apiConstant.apiUrl + 'news';

  static Future<void> getAllNews() async {
    try {
      final response = await http.get(Uri.parse(apiGetAllNews));
      final responseBody = jsonDecode(response.body);
      if (responseBody["status"] == "success") {
        final allNews = responseBody["data"];
        final quantityNews = responseBody["count"];
        newsProvider.setAllNews(allNews);
        newsProvider.setQuantity(quantityNews);
      }
    } catch (e) {
      debugPrint('error from getAllNews: $e');
      rethrow;
    }
  }

  static Future<void> getNewsById(int newsId) async {
    final String apiGetNewsById = apiGetAllNews + '/$newsId';
    try {
      final response = await http.get(Uri.parse(apiGetNewsById));
      if (response.statusCode == 200) {
        newsProvider.setSelectedNews(response.body);
      }
    } catch (e) {
      debugPrint('error from getNewsById: $e');
      rethrow;
    }
  }
}
