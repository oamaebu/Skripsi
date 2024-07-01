import 'package:app/constants.dart';
import 'package:app/provider/game_state_provider.dart';
import 'package:flutter/material.dart';
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
    final List<Map<String, dynamic>> gameStates = gameStateProvider.gameStates;

    final filteredGameStates = gameStates
        .where((state) => state['id_anak'] == widget.parsedChildId)
        .toList();

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
            "Recent Files",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            height: 300,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString());
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: filteredGameStates.map((state) {
                      return FlSpot(
                        state['id'].toDouble(),
                        Duration(
                          hours: int.parse(state['waktu'].split(':')[0]),
                          minutes: int.parse(state['waktu'].split(':')[1]),
                          seconds: int.parse(state['waktu'].split(':')[2]),
                        ).inSeconds.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.amber,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
