import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../model/eggCollection.dart';

class PdfReportGenerator {
  Future<void> generateReport(List<EggCollection> collections, BuildContext context) async {
    // Sort collections by date in ascending order
    collections.sort((a, b) => a.date.compareTo(b.date));

    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Egg and Feed Cost Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Date: ${dateFormat.format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Egg Count', 'Feed Cost'],
                  ...collections.map((collection) => [
                    dateFormat.format(collection.date),
                    collection.count.toString(),
                    collection.feedCost.toStringAsFixed(2),
                  ]),
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
      final downloadsDirectory = Directory(path.join(directory!.path, 'Download'));

      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory.createSync(recursive: true);
      }

      final file = File(path.join(downloadsDirectory.path, 'egg_feed_report.pdf'));
      await file.writeAsBytes(await pdf.save());

      // Show dialog to open the PDF
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Generated'),
          content: const Text('The PDF report has been saved in the Downloads folder. Would you like to open it?'),
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
}
