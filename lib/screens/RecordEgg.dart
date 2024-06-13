import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/eggCollection.dart';
import '../model/egg_collection_provider.dart';

class RecordEggCountsScreen extends StatefulWidget {
  const RecordEggCountsScreen({Key? key}) : super(key: key);

  @override
  _RecordEggCountsScreenState createState() => _RecordEggCountsScreenState();
}

class _RecordEggCountsScreenState extends State<RecordEggCountsScreen> {
  DateTime _selectedDate = DateTime.now();
  final _countController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final count = int.parse(_countController.text);
      final newCollection = EggCollection(date: _selectedDate, count: count);
      await Provider.of<EggCollectionProvider>(context, listen: false)
          .addCollection(newCollection);

      // Show a snackbar to indicate successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Egg counts recorded successfully'),
          duration: Duration(seconds: 2), // Adjust duration as needed
        ),
      );

      Navigator.of(context).pop();
    }
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(), // Adjusted to limit future dates,
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Your Egg Counts'), // More friendly title
        centerTitle: true, // Center the title for better alignment
      ),
      body: SingleChildScrollView(
        // Allow content to scroll if needed
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // Align label and button
                children: [
                  const Text(
                    'Date:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: Text(
                      _selectedDate.toLocal().toString().split(' ')[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Egg Count',
                  hintText: 'e.g., 3', // Helpful hint for users
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // Rounded corners for a softer look
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // Rounded corners for the button
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
