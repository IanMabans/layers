import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/egg_collection_provider.dart';

class RecordFeedCostScreen extends StatefulWidget {
  const RecordFeedCostScreen({super.key});

  @override
  State<RecordFeedCostScreen> createState() => _RecordFeedCostScreenState();
}

class _RecordFeedCostScreenState extends State<RecordFeedCostScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController costController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    void presentDatePicker() async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2021),
        lastDate: DateTime.now(), // Adjusted to limit future dates
      );
      if (pickedDate != null) {
        setState(() { // Assuming this is within a StatefulWidget
          selectedDate = pickedDate;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Feed Cost'),
      ),
      body: SingleChildScrollView( // Allow content to scroll if needed
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: presentDatePicker,
                  child: Text(
                    selectedDate.toLocal().toString().split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: costController,
              decoration: const InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final cost = double.tryParse(costController.text) ?? 0.0;
                Provider.of<EggCollectionProvider>(context, listen: false).updateFeedCost(selectedDate, cost);
                Navigator.pop(context);
              },
              child: const Text('Save'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
