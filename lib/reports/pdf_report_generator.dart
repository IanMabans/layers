import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../model/eggCollection.dart';
import '../model/sale_model.dart';
import '../model/salesDatabaseHelper.dart';

class PdfReportGenerator {
  Future<void> generateReport(
      List<EggCollection> collections, BuildContext context) async {
    // Fetch sales data
    final sales = await SalesDatabaseHelper().getSales();

    // Sort collections and sales by date in ascending order
    collections.sort((a, b) => a.date.compareTo(b.date));
    sales.sort((a, b) => a.date.compareTo(b.date));

    // Merge collections and sales by date
    final combinedData = _mergeCollectionsAndSales(collections, sales);

    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Initialize cumulative totals
    int cumulativeEggs = 0;
    double cumulativeFeedCost = 0.0;
    double cumulativeSales = 0.0;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Egg, Feed Cost, and Sales Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Date: ${dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Egg Count', 'Feed Cost', 'Sales', 'Cumulative Eggs', 'Cumulative Feed Cost', 'Cumulative Sales'],
                  ...combinedData.map(
                        (data) {
                      // Update cumulative totals
                      cumulativeEggs += data['eggCount'] as int;
                      cumulativeFeedCost += data['feedCost'] as double;
                      cumulativeSales += data['sales'] as double;

                      return [
                        dateFormat.format(data['date']),
                        data['eggCount'].toString(),
                        data['feedCost'].toStringAsFixed(2),
                        data['sales'].toStringAsFixed(2),
                        cumulativeEggs.toString(),
                        cumulativeFeedCost.toStringAsFixed(2),
                        cumulativeSales.toStringAsFixed(2),
                      ];
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Request storage permissions
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final downloadsDirectory =
      Directory(path.join(directory!.path, 'Download'));

      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory.createSync(recursive: true);
      }

      final file =
      File(path.join(downloadsDirectory.path, 'egg_feed_sales_report.pdf'));
      await file.writeAsBytes(await pdf.save());

      // Show dialog to open the PDF
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Generated'),
          content: const Text(
              'The PDF report has been saved in the Downloads folder. Would you like to open it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                OpenFile.open(file.path);
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    } else {
      print('Permission denied');
    }
  }

  List<Map<String, dynamic>> _mergeCollectionsAndSales(
      List<EggCollection> collections, List<Sales> sales) {

    final Map<DateTime, Map<String, dynamic>> combinedData = {};

    // Initialize combinedData with egg collections
    for (var collection in collections) {
      combinedData[collection.date] = {
        'date': collection.date,
        'eggCount': collection.count,
        'feedCost': collection.feedCost ?? 0.0,
        'sales': 0.0, // Initialize sales as 0.0
      };
    }

    // Merge sales data into combinedData
    for (var sale in sales) {
      if (combinedData.containsKey(sale.date)) {
        // Accumulate the price into the 'sales' field
        combinedData[sale.date]!['sales'] += sale.price;
      } else {
        // If date not found, create a new entry
        combinedData[sale.date] = {
          'date': sale.date,
          'eggCount': 0, // Initialize other fields as needed
          'feedCost': 0.0,
          'sales': sale.price, // Initialize 'sales' with sale price
        };
      }
    }

    // Convert combinedData map values to list and sort by date
    return combinedData.values.toList()
      ..sort((a, b) => a['date'].compareTo(b['date']));
  }

}

