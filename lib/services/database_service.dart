
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class DatabaseService {
  static const String _favoritesKey = 'favorites';
  static const String _cartKey = 'cart';

  // ==============================
  // DATABASE FAVORITES
  // ==============================

  static Future<List<Product>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(_favoritesKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(data);

    return decoded.map((item) {
      return Product.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  static Future<void> addFavorite(Product product) async {
    final favorites = await getFavorites();

    final exists = favorites.any(
      (item) => item.id == product.id,
    );

    if (!exists) {
      favorites.add(product);
    }

    await _saveFavorites(favorites);
  }

  static Future<void> removeFavorite(int id) async {
    final favorites = await getFavorites();

    favorites.removeWhere(
      (product) => product.id == id,
    );

    await _saveFavorites(favorites);
  }

  static Future<bool> isFavorite(int id) async {
    final favorites = await getFavorites();

    return favorites.any(
      (product) => product.id == id,
    );
  }

  static Future<void> _saveFavorites(
    List<Product> favorites,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = favorites.map((product) {
      return {
        'id': product.id,
        'title': product.title,
        'description': product.description,
        'category': product.category,
        'price': product.price,
        'rating': product.rating,
        'stock': product.stock,
        'thumbnail': product.thumbnail,
        'images': product.images,
      };
    }).toList();

    await prefs.setString(
      _favoritesKey,
      jsonEncode(data),
    );
  }

  // ==============================
  // DATABASE CART
  // ==============================

  static Future<List<Map<String, dynamic>>> getCart() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(_cartKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(data);

    return decoded.map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  static Future<void> addToCart(Product product) async {
    final cart = await getCart();

    final index = cart.indexWhere(
      (item) => item['id'] == product.id,
    );

    if (index != -1) {
      final quantity = cart[index]['quantity'] as int;

      cart[index]['quantity'] = quantity + 1;
    } else {
      cart.add({
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'thumbnail': product.thumbnail,
        'quantity': 1,
      });
    }

    await _saveCart(cart);
  }

  static Future<void> updateCartQuantity(
    int id,
    int quantity,
  ) async {
    final cart = await getCart();

    final index = cart.indexWhere(
      (item) => item['id'] == id,
    );

    if (index == -1) return;

    if (quantity <= 0) {
      cart.removeAt(index);
    } else {
      cart[index]['quantity'] = quantity;
    }

    await _saveCart(cart);
  }

  static Future<void> removeFromCart(int id) async {
    final cart = await getCart();

    cart.removeWhere(
      (item) => item['id'] == id,
    );

    await _saveCart(cart);
  }

  static Future<void> _saveCart(
    List<Map<String, dynamic>> cart,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _cartKey,
      jsonEncode(cart),
    );
  }
}
