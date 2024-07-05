import 'package:app/constants.dart';
import 'package:app/provider/game_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  TestState createState() => TestState();
}

class TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    final gameStateProvider = Provider.of<GameStateProvider>(context);
    final List<Map<String, dynamic>> gameStates = gameStateProvider.gameStates;

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
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(label: Text("ID")),
                DataColumn(label: Text("Jumlah Salah")),
                DataColumn(label: Text("Waktu")),
                DataColumn(label: Text("Anak ID")),
              ],
              rows: List.generate(
                gameStates.length,
                (index) {
                  final gameState = gameStates[index];
                  return DataRow(
                    cells: [
                      DataCell(Text(gameState['id'].toString())),
                      DataCell(Text(gameState['jumlah_salah'].toString())),
                      DataCell(Text(gameState['waktu'])),
                      DataCell(Text(gameState['id_gambar'].toString())),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
