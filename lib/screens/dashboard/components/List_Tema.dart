import 'package:app/screens/main/edit_tema.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import 'package:app/models/tema.dart';
import 'package:app/provider/tema_provider.dart';
import 'package:app/screens/main/data_anak.dart';

class ListTema extends StatefulWidget {
  const ListTema({Key? key}) : super(key: key);

  @override
  ListTemaState createState() => ListTemaState();
}

class ListTemaState extends State<ListTema> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _temaController = TextEditingController();

  void _showAddTemaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Tema'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _temaController,
                  decoration: InputDecoration(labelText: 'Nama Tema'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a tema name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final temaProvider =
                      Provider.of<TemaProvider>(context, listen: false);
                  final newId = DateTime.now().millisecondsSinceEpoch;
                  final tema = Tema(
                      id: newId, namaTema: _temaController.text, status: false);
                  temaProvider.addTema(tema);
                  Navigator.of(context).pop();
                  _temaController.clear();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final temaProvider = Provider.of<TemaProvider>(context);
    final List<Tema> temaList = temaProvider.temas;

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
            "List Tema",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: defaultPadding),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(label: Text("Tema")),
                DataColumn(label: Text("Edit")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Delete")), // Add Delete column header
              ],
              rows: List.generate(
                temaList.length,
                (index) {
                  final tema = temaList[index];
                  return DataRow(
                    cells: [
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            if (tema.id != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    childId: tema.id!,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(tema.namaTema),
                        ),
                      ),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            if (tema.id != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UbahStatusTemaPage(
                                    idtema: tema.id!,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text('Edit'),
                        ),
                      ),
                      DataCell(
                        Switch(
                          value: tema.status,
                          onChanged: (value) {
                            if (tema.id != null) {
                              if (value) {
                                temaProvider.setAllTemasToFalseExcept(tema.id);
                              }
                              temaProvider.updateTemaStatus(tema.id!, value);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Unable to update status for this tema'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            temaProvider.deleteTema(tema.id!);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                _showAddTemaDialog(context);
              },
              child: Text('Add Tema'),
            ),
          ),
          SizedBox(height: defaultPadding),
        ],
      ),
    );
  }
}
