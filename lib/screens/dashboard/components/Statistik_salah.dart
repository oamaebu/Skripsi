import 'package:app/constants.dart';
import 'package:app/provider/game_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatistikSalahAnak extends StatefulWidget {
  final String childId;
  late final int parsedChildId;

  StatistikSalahAnak({Key? key, required this.childId}) : super(key: key) {
    parsedChildId = int.tryParse(childId) ?? 0;
  }

  @override
  StatistikSalahAnakState createState() => StatistikSalahAnakState();
}

class StatistikSalahAnakState extends State<StatistikSalahAnak> {
  @override
  Widget build(BuildContext context) {
    final gameStateProvider = Provider.of<GameStateProvider>(context);
    final List<Map<String, dynamic>> gameStates = gameStateProvider.gameStates;
    print('All game states: $gameStates');
    print('Child ID: ${widget.parsedChildId}');

    final filteredGameStates = gameStates
        .where((state) => state['id_anak'] == widget.parsedChildId)
        .toList();
    print('Filtered game states: $filteredGameStates');

    final now = DateTime.now();
    print('Current date: $now');
    final lastFiveDays =
        List<DateTime>.generate(5, (i) => now.subtract(Duration(days: i)));
    print(
        'Last Five Days: ${lastFiveDays.map((d) => DateFormat('yyyy-M-d').format(d)).join(', ')}');

    final Map<String, double> averagePointsByDate = {};
    final Map<String, int> pointsCountByDate = {};
    for (final state in filteredGameStates) {
      final date = DateFormat('yyyy-M-d').parse(state['tanggal']);
      print('Parsing date: ${state['tanggal']} -> $date');
      final dateString = DateFormat('yyyy-M-d').format(date);
      if (lastFiveDays
          .any((d) => DateFormat('yyyy-M-d').format(d) == dateString)) {
        final points = state['poin'] as int;
        if (!averagePointsByDate.containsKey(dateString)) {
          averagePointsByDate[dateString] = 0;
          pointsCountByDate[dateString] = 0;
        }
        averagePointsByDate[dateString] =
            averagePointsByDate[dateString]! + points;
        pointsCountByDate[dateString] = pointsCountByDate[dateString]! + 1;
      }
    }

    for (final dateString in averagePointsByDate.keys.toList()) {
      averagePointsByDate[dateString] =
          (averagePointsByDate[dateString]! / pointsCountByDate[dateString]!)
              .roundToDouble();
    }

    final List<BarChartGroupData> barGroups = [];
    for (final date in lastFiveDays) {
      final dateString = DateFormat('yyyy-M-d').format(date);
      final dayOfWeek = DateFormat('E').format(date);
      final averagePoints = averagePointsByDate[dateString]?.toDouble() ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: lastFiveDays.indexOf(date),
          barRods: [
            BarChartRodData(
              toY: averagePoints,
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Average Points Last 5 Days",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups,
                maxY: 6, // Set a fixed maximum Y value
                minY: 0, // Set a fixed minimum Y value
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= lastFiveDays.length) {
                          return Text('');
                        }
                        final date = lastFiveDays[index];
                        return Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(1),
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
