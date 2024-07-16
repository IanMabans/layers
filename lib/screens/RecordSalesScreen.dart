import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/sales_provider.dart';

class RecordSalesScreen extends StatefulWidget {
  const RecordSalesScreen({Key? key}) : super(key: key);

  @override
  State<RecordSalesScreen> createState() => _RecordSalesScreenState();
}

class _RecordSalesScreenState extends State<RecordSalesScreen> {
  final TextEditingController _cratesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Sales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter Sales Details'),
              const SizedBox(height: 16),
              TextField(
                controller: _cratesController,
                decoration: const InputDecoration(
                  labelText: 'Number of Trays',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Tray',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text(
                'Selected Date: ${_formatDate(_selectedDate)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Select Date'),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _saveSale,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Save Sale'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
    // Alternatively, use DateFormat from intl package for more formatting options
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021, 1),
      lastDate: DateTime(2030, 12),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveSale() {
    if (_cratesController.text.isEmpty || _priceController.text.isEmpty) {
      // Handle case where fields are empty
      return;
    }

    final int crates = int.tryParse(_cratesController.text) ?? 0;
    final double price = double.tryParse(_priceController.text) ?? 0.0;

    Provider.of<SalesProvider>(context, listen: false)
        .addSale(_selectedDate, crates, price);

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _cratesController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
