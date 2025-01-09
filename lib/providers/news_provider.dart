import 'package:flutter/material.dart';

class NewsProvider extends ChangeNotifier {
  List allNews = [];
  int quantity = 0;
  String selectedContentNews = """ """;

  void setAllNews(List newsFromApi) {
    allNews = newsFromApi;
    notifyListeners();
  }

  void setQuantity(int quantityFromApi) {
    quantity = quantityFromApi;
    notifyListeners();
  }

  void setSelectedNews(String contentNews) {
    selectedContentNews = contentNews;
    notifyListeners();
  }
}