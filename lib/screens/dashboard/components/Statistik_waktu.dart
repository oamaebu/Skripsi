import 'package:app/constants.dart';
import 'package:app/provider/game_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatistikWaktuAnak extends StatefulWidget {
  final String childId;
  late final int parsedChildId;

  StatistikWaktuAnak({Key? key, required this.childId}) : super(key: key) {
    parsedChildId = int.tryParse(childId) ?? 0;
  }

  @override
  StatistikWaktuAnakState createState() => StatistikWaktuAnakState();
}

class StatistikWaktuAnakState extends State<StatistikWaktuAnak> {
  int parseTimeToSeconds(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String formatMinutes(double minutes) {
    final intMinutes = minutes.toInt();
    final seconds = ((minutes - intMinutes) * 60).round();
    return '${intMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameStateProvider = Provider.of<GameStateProvider>(context);
    final List<Map<String, dynamic>> gameStates = gameStateProvider.gameStates;

    final filteredGameStates = gameStates
        .where((state) => state['id_anak'] == widget.parsedChildId)
        .toList();

    final now = DateTime.now();
    final lastFiveDays =
        List<DateTime>.generate(5, (i) => now.subtract(Duration(days: i)));

    final Map<String, List<int>> timesByDate = {};
    for (final state in filteredGameStates) {
      final date = DateFormat('yyyy-M-d').parse(state['tanggal']);
      final dateString = DateFormat('yyyy-M-d').format(date);
      if (lastFiveDays
          .any((d) => DateFormat('yyyy-M-d').format(d) == dateString)) {
        final timeInSeconds = parseTimeToSeconds(state['waktu'] as String);
        if (!timesByDate.containsKey(dateString)) {
          timesByDate[dateString] = [];
        }
        timesByDate[dateString]!.add(timeInSeconds);
      }
    }

    final Map<String, double> averageTimeByDate = {};
    timesByDate.forEach((date, times) {
      if (times.isNotEmpty) {
        averageTimeByDate[date] = times.reduce((a, b) => a + b) / times.length;
      }
    });

    final List<BarChartGroupData> barGroups = [];
    double maxMinutes = 0;
    for (final date in lastFiveDays) {
      final dateString = DateFormat('yyyy-M-d').format(date);
      final averageTimeInSeconds = averageTimeByDate[dateString] ?? 0.0;
      final averageTimeInMinutes = averageTimeInSeconds / 60;

      maxMinutes =
          averageTimeInMinutes > maxMinutes ? averageTimeInMinutes : maxMinutes;

      barGroups.add(
        BarChartGroupData(
          x: lastFiveDays.indexOf(date),
          barRods: [
            BarChartRodData(
              toY: averageTimeInMinutes,
              color: Colors.blue,
              width: 22, // Adjust this value to change bar width
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    // Round up maxMinutes to the nearest 5
    maxMinutes = (maxMinutes / 5).ceil() * 5.0;

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
            "Average Times Last 5 Days",
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
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(formatMinutes(value));
                      },
                      reservedSize: 40,
                    ),
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
                maxY: maxMinutes,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(0),
                    tooltipMargin: 8,
                    getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                    ) {
                      return BarTooltipItem(
                        formatMinutes(rod.toY),
                        const TextStyle(
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
