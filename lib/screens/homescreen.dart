import 'package:flutter/material.dart';
import 'Calendar Screen.dart';
import 'Feeds.dart';
import 'RecordEgg.dart';
import 'View Data.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecordEggCountsScreen()),
                );
              },
              child: const Text('Record Egg Counts'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewDataInGraphsScreen()),
                );
              },
              child: const Text('View Data in Graphs'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                );
              },
              child: const Text('Manage Calendar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecordFeedCostScreen()), // New button for recording feed costs
                );
              },
              child: const Text('Record Feed Costs'),
            ),
          ],
        ),
      ),
    );
  }
}
