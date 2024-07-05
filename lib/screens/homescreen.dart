import 'package:flutter/material.dart';
import 'Calendar Screen.dart';
import 'Feeds.dart';
import 'RecordEgg.dart';
import 'View Data.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final double horizontalPadding = 40;
  final double verticalPadding = 25;

  final List<Map<String, dynamic>> myPages = [
    {
      'name': 'Record Eggs',
      'icon': Icons.egg,
      'route': const RecordEggCountsScreen(),
    },
    {
      'name': 'View Graphs',
      'icon': Icons.bar_chart,
      'route': const ViewDataInGraphsScreen(),
    },
    {
      'name': 'View Calendar',
      'icon': Icons.calendar_today,
      'route': const CalendarScreen(),
    },
    {
      'name': 'Record Feed Costs',
      'icon': Icons.attach_money,
      'route': const RecordFeedCostScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mother Hen 🐔', style: TextStyle(fontSize: 34),),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Divider(
                thickness: 1,
                color: Color.fromARGB(255, 204, 204, 204),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(25),
                itemCount: myPages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.3,
                  mainAxisSpacing: 20, // Adjust as needed
                  crossAxisSpacing: 20, // Adjust as needed
                ),
                itemBuilder: (context, index) {
                  final page = myPages[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => page['route']),
                      );
                    },
                    child: Card(
                      color: Colors.amberAccent,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(page['icon'], size: 50, color: Colors.grey[800]),
                          const SizedBox(height: 20),
                          Text(
                            page['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
