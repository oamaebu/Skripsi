import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/gambar_provider.dart';
import 'package:flutter/material.dart';
import 'package:app/provider/game_state_provider.dart';
import 'package:app/constants.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatistikAnak extends StatefulWidget {
  final String childId;
  late final int parsedChildId;

  StatistikAnak({Key? key, required this.childId}) : super(key: key) {
    parsedChildId = int.tryParse(childId) ?? 0;
  }

  @override
  StatistikAnakState createState() => StatistikAnakState();
}

class StatistikAnakState extends State<StatistikAnak> {
  @override
  Widget build(BuildContext context) {
    final gameStateProvider = Provider.of<GameStateProvider>(context);
    final isiGambarProvider = Provider.of<IsiGambarProvider>(context);
    final List<Map<String, dynamic>> gameStates = gameStateProvider.gameStates;
    final List<IsiGambar> isiGambarList = isiGambarProvider.isiGambarList;

    final filteredGameStates = gameStates
        .where((state) => state['id_anak'] == widget.parsedChildId)
        .toList();

    // Create a map of id_gambar to label
    final Map<int, String> idToLabelMap = {
      for (var isiGambar in isiGambarList)
        if (isiGambar.id != null) isiGambar.id!: isiGambar.label,
    };

    // Group by id_gambar and calculate average time
    final Map<String, List<double>> groupedByLabel = {};

    for (var state in filteredGameStates) {
      final idGambar = state['id_gambar'];
      final label = idToLabelMap[idGambar] ?? 'Unknown';

      final waktuParts = state['waktu'].split(':');
      final durationInSeconds = Duration(
        hours: int.parse(waktuParts[0]),
        minutes: int.parse(waktuParts[1]),
        seconds: int.parse(waktuParts[2]),
      ).inSeconds.toDouble();

      if (!groupedByLabel.containsKey(label)) {
        groupedByLabel[label] = [];
      }

      groupedByLabel[label]!.add(durationInSeconds);
    }

    final List<BarChartGroupData> barGroups = [];

    groupedByLabel.forEach((label, times) {
      final averageTime = times.reduce((a, b) => a + b) / times.length;
      barGroups.add(
        BarChartGroupData(
          x: label.hashCode,
          barRods: [
            BarChartRodData(
              toY: averageTime,
              color: Colors.amber,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    });

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
            "Average Time by Image Label",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: groupedByLabel.values
                        .expand((times) => times)
                        .reduce((a, b) => a > b ? a : b) +
                    10,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString());
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final label = groupedByLabel.keys.firstWhere(
                            (key) => key.hashCode == value.toInt(),
                            orElse: () => 'Unknown');
                        return Text(label);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                barGroups: barGroups,
                gridData: FlGridData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
