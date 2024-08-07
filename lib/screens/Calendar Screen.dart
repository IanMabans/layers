import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/eggCollection.dart';
import '../model/egg_collection_provider.dart';
import '../reports/pdf_report_generator.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final provider = Provider.of<EggCollectionProvider>(context, listen: false);
              final collections = provider.collections;
              final pdfGenerator = PdfReportGenerator();
              await pdfGenerator.generateReport(collections, context);
            },
          ),
        ],
      ),
      body: Consumer<EggCollectionProvider>(
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
                  final totalEggs = provider.collections
                      .where((collection) => isSameDay(collection.date, day))
                      .fold<int>(0, (sum, collection) => sum + collection.count);
                  return totalEggs > 0 ? [totalEggs] : [];
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) {
                    final events = provider.collections
                        .where((collection) => isSameDay(collection.date, date))
                        .toList();
                    final hasEvents = events.isNotEmpty;

                    return Container(
                      decoration: BoxDecoration(
                        color: hasEvents ? Colors.lightBlueAccent : null,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: hasEvents ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return null;
                    final totalEggs = events.first as int;
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: Center(
                          child: Text(
                            '$totalEggs',
                            style: const TextStyle().copyWith(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  final events = provider.collections
                      .where((collection) => isSameDay(collection.date, selectedDay))
                      .toList();

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                          'Details on ${selectedDay.toLocal().toString().split(' ')[0]}'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: events.isEmpty
                            ? [const Text('No data for this day.')]
                            : events
                            .map(
                              (event) => ListTile(
                            title: Text('Collected: ${event.count} eggs'),
                            subtitle: Text('Feed Cost: \$${event.feedCost}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDelete(
                                  context, provider, event),
                            ),
                          ),
                        )
                            .toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _showFeedCostDialog(
                                context, provider, selectedDay);
                          },
                          child: const Text('Add Feed Cost'),
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
    );
  }

  Widget _buildMonthlySummary(EggCollectionProvider provider) {
    final collections = provider.collections
        .where((collection) =>
    collection.date.year == _selectedMonth.year &&
        collection.date.month == _selectedMonth.month)
        .toList();

    final totalEggs = collections.fold<int>(0, (sum, collection) => sum + collection.count);
    final totalFeedCost = collections.fold<double>(0.0, (sum, collection) => sum + (collection.feedCost ?? 0.0));
    final averageEggsPerDay = collections.isEmpty ? 0 : totalEggs / collections.length;

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
                  const Text('Total Eggs Collected:'),
                  Text('$totalEggs'),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Feed Cost:'),
                  Text('\$${totalFeedCost.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Average Eggs per Day:'),
                  Text('${averageEggsPerDay.toStringAsFixed(1)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedCostDialog(BuildContext context, EggCollectionProvider provider, DateTime date) {
    final TextEditingController _costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Feed Cost'),
        content: TextField(
          controller: _costController,
          decoration: const InputDecoration(hintText: 'Enter cost'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final cost = double.tryParse(_costController.text) ?? 0.0;
              provider.updateFeedCost(date, cost);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, EggCollectionProvider provider, EggCollection collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteCollection(collection.id!);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
