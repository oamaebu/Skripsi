import 'package:app/constants.dart';
import 'package:app/controllers/MenuAppController.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:app/provider/game_state_provider.dart';
import 'package:app/responsive.dart';
import 'package:app/screens/dashboard/components/Statistik%20copy.dart';
import 'package:app/screens/dashboard/components/Statistik_salah.dart';
import 'package:app/screens/dashboard/components/Statistik_waktu.dart';
import 'package:app/screens/dashboard/components/profil_anak.dart';

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

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // We want this side menu only for large screen

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
                      SizedBox(height: 25),
                      Test(),
                      SizedBox(height: 25),
                      StatistikSalahAnak(childId: childId.toString(), skema: 1),
                      SizedBox(height: 25),
                      StatistikSalahAnak(childId: childId.toString(), skema: 2),
                      SizedBox(height: 25),
                      StatistikSalahAnak(childId: childId.toString(), skema: 3),
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
