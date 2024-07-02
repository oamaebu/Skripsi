import 'package:app/models/Anak.dart';
import 'package:app/provider/tema_provider.dart';
import 'package:app/screens/children/game/skema2quiz.dart';
import 'package:app/screens/children/game/skema3.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/auth/auth_service.dart';
import 'package:app/component/homepage_drawer.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:app/provider/skema_provider.dart';
import 'package:app/screens/children/game/garis/garis.dart';
import 'package:app/screens/children/game/skema1quiz.dart';
import 'package:app/screens/children/game/matematika/matematika.dart';
import 'package:app/screens/children/game/skema2.dart';
import 'package:app/screens/children/game/skema1.dart';
import 'package:app/screens/children/game/skema3quiz.dart';

class HomePage extends StatefulWidget {
  final bool quiz;

  HomePage({Key? key, required this.quiz}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> allGames;
  late Future<void> _fetchAnakFuture;
  late int? activeTemaId; // Store active tema id here

  @override
  void initState() {
    super.initState();
    activeTemaId =
        Provider.of<TemaProvider>(context, listen: false).getActiveTemaId();

    // Define all possible games
    allGames = [
      {
        "title": "skema1",
        "icon": Icons.menu_book,
        "route": widget.quiz
            ? LevelPagetest(childId: '1', level: 1, idTema: activeTemaId!)
            : Skema1(idTema: activeTemaId!),
        "skemaId": '0'
      },
      {
        "title": "skema2",
        "icon": Icons.numbers,
        "route": widget.quiz
            ? JigsawPuzzleScreenSkema2quiz(idTema: activeTemaId!)
            : JigsawPuzzleScreenSkema2(idTema: activeTemaId!),
        "skemaId": '1'
      },
      {
        "title": "skema3",
        "icon": Icons.category,
        "route": widget.quiz
            ? JigsawPuzzleScreenSkema3quiz(idTema: activeTemaId!)
            : JigsawPuzzleScreenSkema3(idTema: activeTemaId!),
        "skemaId": '2'
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final anakProvider = Provider.of<AnakProvider>(context);
    final currentAnak = anakProvider.currentAnak;
    final skemaProvider = Provider.of<SkemaProvider>(context);

    // Filter games based on skema status
    final activeGames = allGames.where((game) {
      final skema =
          skemaProvider.skemaList.firstWhere((s) => s.id == game['skemaId']);
      return skema.statusSkema == true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      drawer: HomepageDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.quiz)
              Text(
                'Quiz Mode',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  Text(
                    currentAnak?.nama ?? '',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: activeGames.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildCard(
                    activeGames[index]['title'],
                    activeGames[index]['icon'],
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => activeGames[index]['route'],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final _authService = AuthService();
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/LoginPage');
  }

  Widget _buildCard(String title, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.blue,
              ),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
