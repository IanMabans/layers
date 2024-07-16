import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/sale_model.dart';
import '../model/sales_provider.dart';
import 'RecordSalesScreen.dart';

class SalesCalendarScreen extends StatefulWidget {
  const SalesCalendarScreen({super.key});

  @override
  State<SalesCalendarScreen> createState() => _SalesCalendarScreenState();
}

class _SalesCalendarScreenState extends State<SalesCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Calendar'),
      ),
      body: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2021, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _selectedMonth,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _selectedMonth = focusedDay;
                  });
                },
                eventLoader: (day) {
                  return provider.sales
                      .where((sale) => isSameDay(sale.date, day))
                      .toList();
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) {
                    final sales = provider.sales
                        .where((sale) => isSameDay(sale.date, date))
                        .toList();
                    final hasSales = sales.isNotEmpty;

                    return Container(
                      decoration: BoxDecoration(
                        color: hasSales ? Colors.lightGreen : null,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: hasSales ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return null;
                    final sale = events.first as Sales;
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Text(
                            '${sale.quantity}',
                            style: const TextStyle().copyWith(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  final sales = provider.sales
                      .where((sale) => isSameDay(sale.date, selectedDay))
                      .toList();

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                          'Sales on ${selectedDay.toLocal().toString().split(' ')[0]}'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: sales.isEmpty
                            ? [const Text('No sales recorded for this day.')]
                            : sales
                            .map(
                              (sale) => ListTile(
                            title: Text('Sold: ${sale.quantity} Trays'),
                            subtitle: Text('Price: \$${sale.price}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDelete(
                                  context, provider, sale),
                            ),
                          ),
                        )
                            .toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              _buildMonthlySummary(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const RecordSalesScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthlySummary(SalesProvider provider) {
    final sales = provider.sales
        .where((sale) =>
    sale.date.year == _selectedMonth.year &&
        sale.date.month == _selectedMonth.month)
        .toList();

    final totalSales = sales.fold<int>(0, (sum, sale) => sum + sale.quantity);
    final totalRevenue = sales.fold<double>(0.0, (sum, sale) => sum + sale.price);
    final averageSalesPerDay = sales.isEmpty ? 0 : totalSales / sales.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Monthly Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Sales:'),
                  Text('$totalSales Trays'),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Revenue:'),
                  Text('\$${totalRevenue.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Average Sales per Day:'),
                  Text(averageSalesPerDay.toStringAsFixed(2)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _confirmDelete(BuildContext context, SalesProvider provider, Sales sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this sale?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteSale(sale.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
