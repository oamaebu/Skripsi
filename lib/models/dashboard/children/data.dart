import 'package:flutter/foundation.dart';

class Child {
  final String id;
  final String name;

  Child({required this.id, required this.name});
}

class GameLevel {
  final int level;
  bool isCompleted;
  int? timeTaken; // time taken to complete the level in seconds

  GameLevel({required this.level, this.isCompleted = false, this.timeTaken});
}

class GameState extends ChangeNotifier {
  Child? currentChild;
  List<GameLevel> levels = [
    GameLevel(level: 1),
    GameLevel(level: 2),
    GameLevel(level: 3),
  ];

  void login(Child child) {
    currentChild = child;
    notifyListeners();
  }

  void completeLevel(int level, int timeTaken) {
    final gameLevel = levels.firstWhere((l) => l.level == level);
    gameLevel.isCompleted = true;
    gameLevel.timeTaken = timeTaken;
    notifyListeners();
  }

  bool isLevelCompleted(int level) {
    return levels.firstWhere((l) => l.level == level).isCompleted;
  }

  int? getTimeTakenForLevel(int level) {
    return levels.firstWhere((l) => l.level == level).timeTaken;
  }
}
