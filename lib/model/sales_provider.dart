// model/sales_provider.dart

import 'package:flutter/material.dart';
import 'package:layers/model/sale_model.dart';
import 'package:uuid/uuid.dart';


class SalesProvider with ChangeNotifier {
  final List<Sales> _sales = [];

  List<Sales> get sales => _sales;

  void addSale(DateTime date, int quantity, double price) {
    final newSale = Sales(
      id: const Uuid().v4(),
      date: date,
      quantity: quantity,
      price: price,
    );
    _sales.add(newSale);
    notifyListeners();
  }

  void deleteSale(String id) {
    _sales.removeWhere((sale) => sale.id == id);
    notifyListeners();
  }
}
