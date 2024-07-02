import 'package:app/models/dashboard/children/data.dart';
import 'package:app/provider/gambar_provider.dart';
import 'package:app/provider/tema_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/login_or_register.dart';
import 'constants.dart';
import 'controllers/MenuAppController.dart';

import 'models/user.dart';
import 'provider/anak_provider.dart';
import 'provider/game_provider.dart';
import 'provider/game_state_provider.dart';
import 'provider/garis_provider.dart';
import 'provider/puzzle_provider.dart';
import 'provider/skema_provider.dart';
import 'screens/SignUp.dart';
import 'screens/children/game/game.dart';
import 'screens/dashboard/components/List_Anak.dart';
import 'screens/main/buat_profil_anak.dart';
import 'screens/main/main_screen.dart';
import 'screens/login.dart';
import 'screens/children/homepage.dart';
import 'screens/children/game/skema1quiz.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MenuAppController()),
        ChangeNotifierProvider(create: (context) => GameState()),
        ChangeNotifierProvider(create: (context) => AnakProvider()),
        ChangeNotifierProvider(create: (context) => GameProvider()),
        ChangeNotifierProvider(create: (context) => PuzzleProvider()),
        ChangeNotifierProvider(create: (context) => GarisProvider()),
        ChangeNotifierProvider(create: (context) => GameStateProvider()),
        ChangeNotifierProvider(create: (context) => IsiGambarProvider()),
        ChangeNotifierProvider(create: (context) => SkemaProvider()),
        ChangeNotifierProvider(create: (context) => TemaProvider()),
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, userModel, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Admin Panel',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: bgColor,
            textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
                .apply(bodyColor: Color.fromARGB(255, 255, 255, 255)),
            canvasColor: secondaryColor,
          ),
          home: FutureBuilder<bool>(
            future: userModel.checkLoginStatus(context),
            builder: (context, snapshot) {
              print('Snapshot: $snapshot'); // Check what snapshot contains
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                if (snapshot.hasError) {
                  print(
                      'Error: ${snapshot.error}'); // Check if there's an error
                  return ErrorScreen(); // Display an ErrorScreen widget on error
                } else {
                  print(
                      'Logged In: ${snapshot.data}'); // Check if user is logged in
                  return snapshot.data == true ? MainScreen() : LoginPage();
                }
              }
            },
          ),
          routes: {
            '/SignUp': (context) => SignUpPage(),
            '/MainScreen': (context) => MainScreen(),
            '/ListAnak': (context) => ListAnak(),
            '/profilanak': (context) => BuatProfilAnak(),
            '/LoginPage': (context) =>
                LoginPage(), // Define LoginPage route here
          },
        );
      },
    );
  }
}

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
      ),
      body: Center(
        child: Text('An error occurred. Please try again later.'),
      ),
    );
  }
}
