
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/product.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'online_shop.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            category TEXT,
            price REAL,
            rating REAL,
            stock INTEGER,
            thumbnail TEXT,
            images TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY,
            title TEXT,
            price REAL,
            thumbnail TEXT,
            quantity INTEGER
          )
        ''');
      },
    );

    return _database!;
  }

  static Future<void> addFavorite(Product product) async {
    final db = await database;

    await db.insert(
      'favorites',
      {
        'id': product.id,
        'title': product.title,
        'description': product.description,
        'category': product.category,
        'price': product.price,
        'rating': product.rating,
        'stock': product.stock,
        'thumbnail': product.thumbnail,
        'images': product.images.join('|'),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Product>> getFavorites() async {
    final db = await database;
    final data = await db.query('favorites');

    return data.map((item) {
      return Product(
        id: item['id'] as int,
        title: item['title'] as String,
        description: item['description'] as String,
        category: item['category'] as String,
        price: (item['price'] as num).toDouble(),
        rating: (item['rating'] as num).toDouble(),
        stock: item['stock'] as int,
        thumbnail: item['thumbnail'] as String,
        images: (item['images'] as String)
            .split('|')
            .where((image) => image.isNotEmpty)
            .toList(),
      );
    }).toList();
  }

  static Future<bool> isFavorite(int id) async {
    final db = await database;

    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );

    return result.isNotEmpty;
  }

  static Future<void> removeFavorite(int id) async {
    final db = await database;

    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> addToCart(Product product) async {
    final db = await database;

    final result = await db.query(
      'cart',
      where: 'id = ?',
      whereArgs: [product.id],
    );

    if (result.isNotEmpty) {
      final quantity = result.first['quantity'] as int;

      await db.update(
        'cart',
        {'quantity': quantity + 1},
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } else {
      await db.insert('cart', {
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'thumbnail': product.thumbnail,
        'quantity': 1,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getCart() async {
    final db = await database;
    return db.query('cart');
  }

  static Future<void> updateCartQuantity(
    int id,
    int quantity,
  ) async {
    final db = await database;

    if (quantity <= 0) {
      await removeFromCart(id);
      return;
    }

    await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> removeFromCart(int id) async {
    final db = await database;

    await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
