import 'package:sqflite/sqflite.dart';
///this file helps to create the sqllite schema
class DbSchemaSeed {
  static Future<void> createAndSeed(Database db, int version) async {
    // Comments Table
    await db.execute('''
      CREATE TABLE Comments (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        image TEXT
      )
    ''');

    List<Map<String, dynamic>> commentsData = [
      {
        "id": 1,
        "title": "COP APP",
        "description": "The COP application is under development",
        "image": "application.png"
      },
      {
        "id": 2,
        "title": "Team",
        "description": "The development team is actively training and preparing modules",
        "image": "pixel.png"
      },
      {
        "id": 3,
        "title": "Team",
        "description": "These are comments from sqlite database",
        "image": "pixel.png"
      },
    ];

    for (var item in commentsData) {
      await db.insert("Comments", item);
    }

    // Products Table
    await db.execute('''
      CREATE TABLE Products (
        id INTEGER PRIMARY KEY,
        name TEXT,
        description TEXT,
        price INTEGER,
        image TEXT
      )
    ''');

    List<Map<String, dynamic>> productsData = [
      {
        "id": 1,
        "name": "iPhone",
        "description": "iPhone is the most stylish phone ever",
        "price": 1000,
        "image": "iphone.png"
      },
      {
        "id": 2,
        "name": "Pixel",
        "description": "Pixel is the most feature-rich phone ever",
        "price": 800,
        "image": "pixel.png"
      },
    ];

    for (var item in productsData) {
      await db.insert("Products", item);
    }
  }
}
