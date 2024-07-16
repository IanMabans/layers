import 'package:layers/model/sale_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SalesDatabaseHelper {
  static final SalesDatabaseHelper _instance = SalesDatabaseHelper._internal();
  factory SalesDatabaseHelper() => _instance;
  static Database? _database;

  SalesDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'sales.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE sales(id TEXT PRIMARY KEY, date TEXT, quantity INTEGER, price REAL)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertSale(Sales sale) async {
    final db = await database;
    await db.insert('sales', sale.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteSale(String id) async {
    final db = await database;
    await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Sales>> getSales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sales');
    return List.generate(maps.length, (i) {
      return Sales.fromMap(maps[i]);
    });
  }
}
