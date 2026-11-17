
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class StorageService {
  static const String _cartKey = 'shopping_cart';

  // Mengambil seluruh produk dalam keranjang
  static Future<List<Map<String, dynamic>>> getCart() async {
    final prefs = await SharedPreferences.getInstance();

    final String? cartData = prefs.getString(_cartKey);

    if (cartData == null || cartData.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(cartData);

    return decoded
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // Menambahkan produk ke keranjang
  static Future<void> addToCart(Product product) async {
    final prefs = await SharedPreferences.getInstance();

    final cart = await getCart();

    final index = cart.indexWhere(
      (item) => item['id'] == product.id,
    );

    if (index != -1) {
      cart[index]['quantity'] =
          (cart[index]['quantity'] as int) + 1;
    } else {
      cart.add({
        'id': product.id,
        'title': product.title,
        'description': product.description,
        'category': product.category,
        'price': product.price,
        'rating': product.rating,
        'stock': product.stock,
        'thumbnail': product.thumbnail,
        'images': product.images,
        'quantity': 1,
      });
    }

    await prefs.setString(_cartKey, jsonEncode(cart));
  }

  // Menghapus produk dari keranjang
  static Future<void> removeFromCart(int productId) async {
    final prefs = await SharedPreferences.getInstance();

    final cart = await getCart();

    cart.removeWhere(
      (item) => item['id'] == productId,
    );

    await prefs.setString(_cartKey, jsonEncode(cart));
  }

  // Mengubah jumlah produk
  static Future<void> updateQuantity(
    int productId,
    int quantity,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final cart = await getCart();

    final index = cart.indexWhere(
      (item) => item['id'] == productId,
    );

    if (index != -1) {
      if (quantity <= 0) {
        cart.removeAt(index);
      } else {
        cart[index]['quantity'] = quantity;
      }
    }

    await prefs.setString(_cartKey, jsonEncode(cart));
  }

  // Mengosongkan keranjang
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_cartKey);
  }
}
