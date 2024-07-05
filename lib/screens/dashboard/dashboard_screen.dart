import 'package:app/screens/dashboard/components/ListSkema.dart';
import 'package:app/screens/dashboard/components/List_Tema.dart';
import 'package:flutter/material.dart';
import 'package:app/responsive.dart';
import 'package:app/screens/dashboard/components/list_anak.dart';
import 'package:app/screens/dashboard/components/head.dart';
import 'components/header.dart';
import 'components/profil_anak.dart';
import '../../constants.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MyFiles(),
                      SizedBox(height: defaultPadding),
                      ListSkema(),
                      SizedBox(height: defaultPadding),
                      ListTema(),
                      SizedBox(height: 10),
                      ListAnak(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
