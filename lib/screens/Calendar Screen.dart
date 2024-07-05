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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final provider =
              Provider.of<EggCollectionProvider>(context, listen: false);
              final collections = provider.collections;
              final pdfGenerator = PdfReportGenerator();
              await pdfGenerator.generateReport(collections, context);
            },
          ),
        ],
      ),
      body: Consumer<EggCollectionProvider>(
        builder: (context, provider, child) {
          return TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) {
              return provider.collections
                  .where((collection) => isSameDay(collection.date, day))
                  .toList();
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          '${events.length}',
                          style: const TextStyle().copyWith(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              final events = provider.collections
                  .where(
                      (collection) => isSameDay(collection.date, selectedDay))
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
                        subtitle:
                        Text('Feed Cost: \$${event.feedCost}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _confirmDelete(context, provider, event),
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
                    TextButton(
                      onPressed: () {
                        _showFeedCostDialog(context, provider, selectedDay);
                      },
                      child: const Text('Add Feed Cost'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFeedCostDialog(
      BuildContext context, EggCollectionProvider provider, DateTime date) {
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

  void _confirmDelete(
      BuildContext context, EggCollectionProvider provider, EggCollection collection) {
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
