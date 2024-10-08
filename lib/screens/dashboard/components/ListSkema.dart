import 'package:app/constants.dart';
import 'package:app/models/skema.dart';
import 'package:app/provider/skema_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListSkema extends StatefulWidget {
  const ListSkema({Key? key}) : super(key: key);

  @override
  ListSkemaState createState() => ListSkemaState();
}

class ListSkemaState extends State<ListSkema> {
  final List<String> skemaNames = [
    'Pengenalan Objek ',
    'Pilih Objek',
    'Puzzle Jigzaw'
  ]; // Names of schemas

  @override
  Widget build(BuildContext context) {
    final skemaProvider = Provider.of<SkemaProvider>(context);
    final List<Skema> skemaList = skemaProvider.skemaList;

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
            "List Skema",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(label: Text("Skema")),
                DataColumn(label: Text("Status")),
              ],
              rows: List.generate(skemaNames.length, (index) {
                final skemaName = skemaNames[index];
                final skema = skemaList[
                    index]; // Assuming skemaList is properly initialized
                return DataRow(cells: [
                  DataCell(Text(skemaName)),
                  DataCell(
                    Switch(
                      value: skema.statusSkema ?? true,
                      onChanged: (value) {
                        skemaProvider.updateSkemaStatus(skema.id, value);
                      },
                    ),
                  ),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
