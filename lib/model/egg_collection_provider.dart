import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'databaseHelper.dart';
import 'eggCollection.dart';

class EggCollectionProvider with ChangeNotifier {
  List<EggCollection> _collections = [];

  List<EggCollection> get collections => _collections;

  Future<void> fetchCollections() async {
    _collections = await DatabaseHelper().getEggCollections();
    notifyListeners();
  }

  Future<void> addCollection(EggCollection collection) async {
    await DatabaseHelper().insertEggCollection(collection);
    await fetchCollections();
  }

  Future<void> updateFeedCost(DateTime date, double cost) async {
    for (var collection in _collections) {
      if (isSameDay(collection.date, date)) {
        collection.feedCost = cost;
        await DatabaseHelper().insertEggCollection(collection);
        await fetchCollections(); // Fetch and notify listeners
        break;
      }
    }
  }
}
