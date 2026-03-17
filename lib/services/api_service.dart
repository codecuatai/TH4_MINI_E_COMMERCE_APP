import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com/products';

  // Fetch products with pagination
  Future<List<dynamic>> fetchProducts({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?limit=$limit&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Fetch single product by id
  Future<Map<String, dynamic>> fetchProductById(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load product');
    }
  }
}
