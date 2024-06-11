import 'package:flutter/material.dart';
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
    EggCollection? existingCollection =
        await DatabaseHelper().getEggCollectionByDate(date);
    if (existingCollection != null) {
      // Update the existing record with the new feed cost
      final updatedCollection = existingCollection.copyWith(
          feedCost: cost + existingCollection.feedCost);
      await DatabaseHelper().updateEggCollection(updatedCollection);
    } else {
      // Create a new record if none exists for the selected date
      final newCollection = EggCollection(date: date, count: 0, feedCost: cost);
      await addCollection(newCollection);
    }
    await fetchCollections();
  }

  Future<void> addFeedCost(DateTime date, double cost) async {
    final newCollection = EggCollection(date: date, count: 0, feedCost: cost);
    await addCollection(newCollection);
  }

  Future<void> updateEggCount(DateTime date, int count) async {
    EggCollection? existingCollection =
        await DatabaseHelper().getEggCollectionByDate(date);
    if (existingCollection != null) {
      final updatedCollection = existingCollection.copyWith(count: count);
      await DatabaseHelper().updateEggCollection(updatedCollection);
    } else {
      final newCollection =
          EggCollection(date: date, count: count, feedCost: 0.0);
      await addCollection(newCollection);
    }
    await fetchCollections();
  }
}
