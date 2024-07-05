import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'eggCollection.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'egg_collector.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE egg_collections(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, count INTEGER DEFAULT 0, feedCost REAL DEFAULT 0.0)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertEggCollection(EggCollection collection) async {
    final db = await database;
    await db.insert('egg_collections', collection.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEggCollection(EggCollection collection) async {
    final db = await database;
    await db.update('egg_collections', collection.toMap(), where: 'id = ?', whereArgs: [collection.id]);
  }

  Future<List<EggCollection>> getEggCollections() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('egg_collections');
    return List.generate(maps.length, (i) {
      return EggCollection.fromMap(maps[i]);
    });
  }

  Future<EggCollection?> getEggCollectionByDate(DateTime date) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'egg_collections',
        where: 'date = ?',
        whereArgs: [date.toIso8601String()],
      );

      if (maps.isNotEmpty) {
        return EggCollection.fromMap(maps.first);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting collection by date: $e');
      return null;
    }
  }

  Future<void> deleteEggCollection(int id) async {
    final db = await database;
    await db.delete('egg_collections', where: 'id = ?', whereArgs: [id]);
  }
}
