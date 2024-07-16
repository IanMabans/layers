import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/sales_provider.dart';

class RecordSalesScreen extends StatefulWidget {
  const RecordSalesScreen({super.key});

  @override
  State<RecordSalesScreen> createState() => _RecordSalesScreenState();
}

class _RecordSalesScreenState extends State<RecordSalesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Sales'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Sales Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDateField(context),
              const SizedBox(height: 16),
              _buildQuantityField(),
              const SizedBox(height: 16),
              _buildPriceField(),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => _saveSale(context),
                  child: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Date',
        suffixIcon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      decoration: InputDecoration(
        labelText: 'Quantity (trays)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the quantity';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: 'Total Price',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the price';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _saveSale(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final date = _selectedDate!;
      final quantity = int.parse(_quantityController.text);
      final price = double.parse(_priceController.text);

      Provider.of<SalesProvider>(context, listen: false)
          .addSale(date, quantity, price)
          .then((_) => Navigator.pop(context));
    }
  }
}
