import 'package:app/constants.dart';
import 'package:app/models/skema.dart';
import 'package:app/provider/game_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatistikSalahAnak extends StatefulWidget {
  final String childId;
  final int skema;
  late final int parsedChildId;

  StatistikSalahAnak({Key? key, required this.childId, required this.skema})
      : super(key: key) {
    parsedChildId = int.tryParse(childId) ?? 0;
    print('Parsed Child ID: $parsedChildId');
  }

  @override
  StatistikSalahAnakState createState() => StatistikSalahAnakState();
}

class StatistikSalahAnakState extends State<StatistikSalahAnak> {
  int currentStartIndex = 0;
  static const int daysToShow = 5;


  @override
  Widget build(BuildContext context) {
    final gameStateProvider = Provider.of<GameStateProvider>(context);
    final List<Map<String, dynamic>> gameStates = gameStateProvider.gameStates;
    

     int skema = widget.skema;

    final filteredGameStates = gameStates
        .where((state) =>
            state['id_anak'] == widget.parsedChildId &&
            state['skema'] == widget.skema)
        .toList();

    print('Filtered game states: $filteredGameStates');

    if (filteredGameStates.isEmpty) {
      return Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Center(
          child: Text(
            "No data available",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    // Group data by date
    Map<DateTime, Map<String, int>> groupedData = {};
    for (final state in filteredGameStates) {
      final date = DateFormat('yyyy-MM-dd').parse(state['tanggal'] as String);
      final dateKey = DateTime(date.year, date.month, date.day);

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = {'mudah': 0, 'sedang': 0, 'sulit': 0};
      }

      groupedData[dateKey]!['mudah'] = (groupedData[dateKey]!['mudah'] ?? 0) +
          (state['BenarMudah'] as int? ?? 0);
      groupedData[dateKey]!['sedang'] = (groupedData[dateKey]!['sedang'] ?? 0) +
          (state['BenarSedang'] as int? ?? 0);
      groupedData[dateKey]!['sulit'] = (groupedData[dateKey]!['sulit'] ?? 0) +
          (state['BenarSulit'] as int? ?? 0);
    }

    // Sort dates
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Calculate the range of dates to show
    final int endIndex = currentStartIndex + daysToShow;
    final datesToShow = sortedDates.sublist(
      currentStartIndex,
      endIndex > sortedDates.length ? sortedDates.length : endIndex,
    );

    // Create bar groups
    final List<BarChartGroupData> barGroups =
        datesToShow.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final data = groupedData[date]!;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data['mudah']!.toDouble(),
            color: Colors.green,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: data['sedang']!.toDouble(),
            color: Colors.yellow,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: data['sulit']!.toDouble(),
            color: Colors.red,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0, 1, 2],
      );
    }).toList();

    // Calculate max Y value
    final maxY = groupedData.values
        .map((data) => data['mudah']! + data['sedang']! + data['sulit']!)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

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
            "Total Jawaban Benar Skema $skema",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 20),
          if (barGroups.isNotEmpty)
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barGroups,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < datesToShow.length) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat('dd/MM')
                                    .format(datesToShow[value.toInt()]),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval:
                        maxY / 5, // Adjust this value to change grid density
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.2),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.white.withOpacity(0.5)),
                      bottom: BorderSide(color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String kategori;
                        switch (rodIndex) {
                          case 0:
                            kategori = 'M';
                            break;
                          case 1:
                            kategori = 'S';
                            break;
                          case 2:
                            kategori = 'L';
                            break;
                          default:
                            kategori = '';
                        }
                        return BarTooltipItem(
                          '$kategori:${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Mudah (M)', Colors.green),
              SizedBox(width: 20),
              _buildLegendItem('Sedang (S)', Colors.yellow),
              SizedBox(width: 20),
              _buildLegendItem('Sulit (L)', Colors.red),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: currentStartIndex > 0
                    ? () {
                        setState(() {
                          currentStartIndex -= daysToShow;
                          if (currentStartIndex < 0) currentStartIndex = 0;
                        });
                      }
                    : null,
                child: Text('Previous'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: endIndex < sortedDates.length
                    ? () {
                        setState(() {
                          currentStartIndex += daysToShow;
                          if (currentStartIndex >= sortedDates.length)
                            currentStartIndex = sortedDates.length - daysToShow;
                        });
                      }
                    : null,
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
