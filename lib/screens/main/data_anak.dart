import 'package:app/constants.dart';
import 'package:app/controllers/MenuAppController.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:app/responsive.dart';
import 'package:app/screens/dashboard/components/Statistik%20copy.dart';
import 'package:app/screens/dashboard/components/Statistik_salah.dart';
import 'package:app/screens/dashboard/components/Statistik_waktu.dart';
import 'package:app/screens/dashboard/components/profil_anak.dart';
import 'package:app/screens/main/components/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class DetailPage extends HookWidget {
  final int childId;

  const DetailPage({Key? key, required this.childId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final anakProvider = Provider.of<AnakProvider>(context);
    final currentAnak = anakProvider.currentAnak;
    final ValueNotifier<String> selectedStatistik = useState('waktu');

    // Fetch child's data by ID
    void fetchChildData() {
      anakProvider.fetchAnakById(childId);
    }

    // Fetch child's data when the widget is first built
    useEffect(() {
      fetchChildData();
      return () {}; // Clean-up function
    }, []);

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // We want this side menu only for large screen
              if (Responsive.isDesktop(context))
                Expanded(
                  // default flex = 1
                  // and it takes 1/6 part of the screen
                  child: SideMenu(),
                ),
              Expanded(
                // It takes 5/6 part of the screen
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  
                      SizedBox(height: 10),
                      profilAnak(),
                      SizedBox(height: 25),
                      DropdownButton<String>(
                        value: selectedStatistik.value,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            selectedStatistik.value = newValue;
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'waktu',
                            child: Text('Statistik Waktu'),
                          ),
                          DropdownMenuItem(
                            value: 'salah',
                            child: Text('Statistik Salah'),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      ValueListenableBuilder<String>(
                        valueListenable: selectedStatistik,
                        builder: (context, value, child) {
                          if (value == 'waktu') {
                            return StatistikAnak(childId: childId.toString());
                          } else {
                            return StatistikSalahAnak(
                                childId: childId.toString());
                          }
                        },
                      ),
                      SizedBox(height: 25),
                      Test(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
