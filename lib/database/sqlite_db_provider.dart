import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//this file contains the sqllite database operations, initialise a schema on
//file db_schema_seed.dart

import 'db_schema_seed.dart'; // Import the separate schema/seed logic

class SQLiteDbProvider {
  SQLiteDbProvider._();
  static final SQLiteDbProvider db = SQLiteDbProvider._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "APHRC-COP.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: DbSchemaSeed.createAndSeed,
    );
  }

  Future<List<T>> getAll<T>({
    required String tableName,
    required T Function(Map<String, dynamic>) fromMap,
    String? orderBy,
  }) async {
    final db = await database;
    final results = await db.query(tableName, orderBy: orderBy ?? "id ASC");
    return results.map((map) => fromMap(map)).toList();
  }

  Future<T?> getById<T>({
    required String tableName,
    required int id,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    final db = await database;
    final result = await db.query(tableName, where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? fromMap(result.first) : null;
  }

  Future<int> insert({
    required String tableName,
    required Map<String, dynamic> values,
  }) async {
    final db = await database;
    final maxIdResult =
    await db.rawQuery("SELECT MAX(id)+1 as last_inserted_id FROM $tableName");
    final id = maxIdResult.first["last_inserted_id"] ?? 1;
    values["id"] = id;
    return await db.insert(tableName, values);
  }

  Future<int> update({
    required String tableName,
    required Map<String, dynamic> values,
    required int id,
  }) async {
    final db = await database;
    return await db.update(
      tableName,
      values,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> delete({
    required String tableName,
    required int id,
  }) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}


////////////////////////////////usage of the provider///////////////////////////////

// // Fetch all comments
// List<Comments> comments = await SQLiteDbProvider.db.getAll<Comments>(
// tableName: "Comments",
// fromMap: (map) => Comments.fromMap(map),
// );
//
// // Insert a new comment
// await SQLiteDbProvider.db.insert(
// tableName: "Comments",
// values: Comments(0, "New Title", "Description", "image.png").toMap(),
// );
//
// // Update a comment
// await SQLiteDbProvider.db.update(
// tableName: "Comments",
// id: 1,
// values: Comments(1, "Updated Title", "Updated Desc", "image.png").toMap(),
// );
//
// // Delete a comment
// await SQLiteDbProvider.db.delete(
// tableName: "Comments",
// id: 1,
// );

////////////////////////////////usage of the provider///////////////////////////////
