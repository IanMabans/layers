import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // New package for charts
import '../model/eggCollection.dart';
import '../model/egg_collection_provider.dart';

class ViewDataInGraphsScreen extends StatelessWidget {
  const ViewDataInGraphsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('View Data in Graphs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GraphView(type: 'daily'),
            GraphView(type: 'weekly'),
            GraphView(type: 'monthly'),
          ],
        ),
      ),
    );
  }
}

class GraphView extends StatelessWidget {
  final String type;

  const GraphView({super.key, required this.type});

  List<EggCollection> _filterData(List<EggCollection> data, String type) {
    DateTime now = DateTime.now();
    if (type == 'daily') {
      return data.where((d) => d.date.day == now.day && d.date.month == now.month && d.date.year == now.year).toList();
    } else if (type == 'weekly') {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
      return data.where((d) => d.date.isAfter(startOfWeek) && d.date.isBefore(endOfWeek)).toList();
    } else if (type == 'monthly') {
      return data.where((d) => d.date.month == now.month && d.date.year == now.year).toList();
    } else {
      return data;
    }
  }

  List<String> _getXAxisLabels(String type) {
    if (type == 'daily') {
      return ['Morning', 'Midday', 'Evening'];
    } else if (type == 'weekly') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (type == 'monthly') {
      return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
    } else {
      return [];
    }
  }

  double _getMaxY(String type) {
    if (type == 'daily' || type == 'weekly') {
      return 150;
    } else if (type == 'monthly') {
      return 1050;
    } else {
      return 0;
    }
  }

  Map<int, double> _aggregateWeeklyData(List<EggCollection> data) {
    Map<int, double> weeklyData = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var collection in data) {
      int weekday = collection.date.weekday;
      weeklyData[weekday] = weeklyData[weekday]! + collection.count.toDouble();
    }
    return weeklyData;
  }

  Map<int, double> _aggregateMonthlyData(List<EggCollection> data) {
    Map<int, double> monthlyData = {0: 0, 1: 0, 2: 0, 3: 0};
    for (var collection in data) {
      int week = (collection.date.day - 1) ~/ 7;
      monthlyData[week] = monthlyData[week]! + collection.count.toDouble();
    }
    return monthlyData;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EggCollectionProvider>(
      builder: (context, provider, child) {
        final data = _filterData(provider.collections, type);
        final xAxisLabels = _getXAxisLabels(type);

        List<BarChartGroupData> barGroups = [];
        if (type == 'weekly') {
          final weeklyData = _aggregateWeeklyData(data);
          barGroups = weeklyData.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key - 1,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Colors.blue,
                  width: 22,
                ),
              ],
            );
          }).toList();
        } else if (type == 'monthly') {
          final monthlyData = _aggregateMonthlyData(data);
          barGroups = monthlyData.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Colors.blue,
                  width: 22,
                ),
              ],
            );
          }).toList();
        } else {
          barGroups = data.map((collection) {
            double xValue;
            int hour = collection.date.hour;
            if (hour >= 0 && hour < 12) {
              xValue = 0; // Morning
            } else if (hour >= 12 && hour < 18) {
              xValue = 1; // Midday
            } else {
              xValue = 2; // Evening
            }
            return BarChartGroupData(
              x: xValue.toInt(),
              barRods: [
                BarChartRodData(
                  toY: collection.count.toDouble(),
                  color: Colors.blue,
                  width: 22,
                ),
              ],
            );
          }).toList();
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxY(type),
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      Widget text;
                      if (type == 'daily') {
                        text = Text(['Morning', 'Midday', 'Evening'][value.toInt()]);
                      } else if (type == 'weekly') {
                        text = Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][value.toInt()]);
                      } else if (type == 'monthly') {
                        text = Text('Week ${value.toInt() + 1}');
                      } else {
                        text = const Text('Undefined');
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: text,
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: type == 'monthly' ? 150 : 30,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor: Colors.blueAccent,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String label;
                    if (type == 'daily') {
                      label = ['Morning', 'Midday', 'Evening'][group.x.toInt()];
                    } else if (type == 'weekly') {
                      label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][group.x.toInt()];
                    } else {
                      label = 'Week ${group.x + 1}';
                    }
                    return BarTooltipItem(
                      '$label\n${rod.toY.toString()} eggs',
                      TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
