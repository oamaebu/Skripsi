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

    final Map<String, int> highestPointsByDate = {};
    for (final state in filteredGameStates) {
      final date = DateFormat('yyyy-M-d').parse(state['tanggal']);
      print('Parsing date: ${state['tanggal']} -> $date');
      final dateString = DateFormat('yyyy-M-d').format(date);
      if (lastFiveDays
          .any((d) => DateFormat('yyyy-M-d').format(d) == dateString)) {
        final points = state['poin'] as int;
        if (!highestPointsByDate.containsKey(dateString) ||
            points > highestPointsByDate[dateString]!) {
          highestPointsByDate[dateString] = points;
        }
      }
    }
    print('Highest points by date: $highestPointsByDate');

    final List<BarChartGroupData> barGroups = [];
    for (final date in lastFiveDays) {
      final dateString = DateFormat('yyyy-M-d').format(date);
      final dayOfWeek = DateFormat('EEEE').format(date);
      final highestPoints = highestPointsByDate[dateString]?.toDouble() ?? 0.0;

      print(
          'Date: $dateString, Day: $dayOfWeek, Highest Points: $highestPoints');

      barGroups.add(
        BarChartGroupData(
          x: lastFiveDays.indexOf(date),
          barRods: [
            BarChartRodData(
              toY: highestPoints,
              color: Colors.blue,
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
            "Highest Points Last 5 Days",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= lastFiveDays.length) {
                          return Text('');
                        }
                        final date = lastFiveDays[index];
                        return Text(DateFormat('E').format(date));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
