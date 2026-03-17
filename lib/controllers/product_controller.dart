import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class ProductController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  ProductController() {
    fetchInitialProducts();
  }

  Future<void> fetchInitialProducts() async {
    _products.clear();
    _page = 1;
    _hasMore = true;
    await fetchProducts(reset: true);
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.fetchProducts(page: _page, limit: _limit);
      final fetched = data.map((e) => ProductModel.fromJson(e)).toList();
      if (reset) {
        _products = fetched;
      } else {
        _products.addAll(fetched);
      }
      if (fetched.length < _limit) {
        _hasMore = false;
      } else {
        _page++;
      }
    } catch (e) {
      // handle error (optionally set error state)
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    await fetchInitialProducts();
  }
}
