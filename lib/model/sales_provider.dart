import 'package:flutter/material.dart';
import 'package:layers/model/salesDatabaseHelper.dart';
import '../model/sale_model.dart';

class SalesProvider with ChangeNotifier {
  List<Sales> _sales = [];
  final SalesDatabaseHelper _dbHelper = SalesDatabaseHelper();

  SalesProvider() {
    _loadSales();
  }

  List<Sales> get sales => _sales;

  Future<void> _loadSales() async {
    _sales = await _dbHelper.getSales();
    notifyListeners();
  }

  Future<void> addSale(DateTime date, int quantity, double price) async {
    final sale = Sales(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      quantity: quantity,
      price: price,
    );
    await _dbHelper.insertSale(sale);
    _sales.add(sale);
    notifyListeners();
  }

  Future<void> deleteSale(String id) async {
    await _dbHelper.deleteSale(id);
    _sales.removeWhere((sale) => sale.id == id);
    notifyListeners();
  }

  void deleteSales(DateTime date) {
    _sales.removeWhere((sale) => sale.date == date);
    notifyListeners();
  }
}
