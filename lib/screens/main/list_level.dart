import 'package:app/constants.dart';
import 'package:app/models/puzzle.dart';
import 'package:app/provider/puzzle_provider.dart';
import 'package:app/responsive.dart';
import 'package:app/screens/children/homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListLevel extends StatelessWidget {
  const ListLevel({super.key});

  @override
  Widget build(BuildContext context) {
    final puzzleProvider = Provider.of<PuzzleProvider>(context);
    final List<puzzle> puzzleList = puzzleProvider.puzzles;

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
                DataColumn(label: Text("kelas")),
                DataColumn(label: Text("Class")),
                DataColumn(label: Text("Play")),
              ],
              rows: List.generate(
                puzzleList.length,
                (index) {
                  final puzzle = puzzleList[index];
                  return DataRow(
                    cells: [
                      DataCell(Text(puzzle.id.toString())),
                      DataCell(Text(puzzle.kelas.toString())),
                      DataCell(Text(puzzle.kelas.toString())),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                           
                          },
                          child: Text('Play Now'),
                        ),
                      ),
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
