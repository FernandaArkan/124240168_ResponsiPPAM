
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {

  static const String baseUrl = 'https://dummyjson.com/products';

  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl?limit=100'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'];

      return products
          .map((item) => Product.fromJson(item))
          .toList();
    }

    throw Exception(
      'Gagal mengambil data produk: ${response.statusCode}',
    );
  }

  static Future<Product> getProductDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Product.fromJson(data);
    }

    throw Exception(
      'Gagal mengambil detail produk: ${response.statusCode}',
    );
  }

  static Future<List<Product>> searchProducts(
    String query,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/search?q=${Uri.encodeQueryComponent(query)}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'];

      return products
          .map((item) => Product.fromJson(item))
          .toList();
    }

    throw Exception(
      'Gagal mencari produk: ${response.statusCode}',
    );
  }


  static Future<List<Product>> getProductsByCategory(
    String category,
  ) async {
    final encodedCategory = Uri.encodeComponent(category);

    final response = await http.get(
      Uri.parse('$baseUrl/category/$encodedCategory'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'];

      return products
          .map((item) => Product.fromJson(item))
          .toList();
    }

    throw Exception(
      'Gagal mengambil kategori produk: ${response.statusCode}',
    );
  }

  static Future<List<String>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/category-list'),
    );

    if (response.statusCode == 200) {
      final List categories = jsonDecode(response.body);

      return categories
          .map((category) => category.toString())
          .toList();
    }

    throw Exception(
      'Gagal mengambil daftar kategori: ${response.statusCode}',
    );
  }
}
