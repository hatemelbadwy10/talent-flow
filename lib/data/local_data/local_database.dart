import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../config/mapper.dart';

class LocaleDatabase {
  LocaleDatabase();
  late Database database;
  Future<void> initDatabase({String? initialTableName}) async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'doggie_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE ${initialTableName ?? "Items"}(id TEXT PRIMARY KEY, title TEXT, image TEXT, price DOUBLE, count INTEGER, size TEXT, color TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertEntity(
      {required String tableName, required LocaleSingleMapper object}) async {
    await database.insert(
      tableName,
      object.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateEntity(
      {required String tableName,
      required String id,
      required LocaleSingleMapper object}) async {
    return await database.update(
      tableName,
      object.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteEntity(
      {required String id, required String tableName}) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocaleSingleMapper>> getEntities(
      {required LocaleSingleMapper objectModel,
      required String tableName}) async {
    final List<LocaleSingleMapper> models = (await database.query(tableName))
        .map((map) => objectModel.fromMapper(map) as LocaleSingleMapper)
        .toList();
    return models;
  }

  Future<void> deleteTable({required String tableName}) async {
    await database.delete(tableName);
  }
}
