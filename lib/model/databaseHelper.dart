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
          'CREATE TABLE egg_collections(id INTEGER PRIMARY KEY, date TEXT, count INTEGER, feedCost REAL)', // Ensure feedCost column is created
        );
      },
      version: 1,
    );
  }

  Future<void> insertEggCollection(EggCollection collection) async {
    final db = await database;
    await db.insert('egg_collections', collection.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<EggCollection>> getEggCollections() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('egg_collections');
    return List.generate(maps.length, (i) {
      return EggCollection.fromMap(maps[i]);
    });
  }
}
