import 'package:flutter/material.dart';
import 'package:kare/pages/defines.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  late SharedPreferences prefs;
  int bestScore = 0;
  bool hintsEnabled = true;
  bool undoEnabled = true;
  bool showNumbers = true;
  bool forwardEnabled = true;
  int width = 5;
  int height = 5;
  int get volume => width * height;
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<T> readWrite<T>(
    bool status,
    String key,
    T value,
  ) async {
    if (T == int) {
      if (status) {
        final a = (prefs.getInt(key) ?? value) as T;
        return a;
      } else {
        await prefs.setInt(key, value as int);
        return value;
      }
    } else if (T == bool) {
      if (status) {
        return (prefs.getBool(key) ?? value) as T;
      } else {
        await prefs.setBool(key, value as bool);
        return value;
      }
    } else {
      throw Exception("Unsupported type");
    }
  }

  Future<void> store({required bool rW}) async {
    hintsEnabled = await readWrite<bool>(rW, 'hintsEnabled', hintsEnabled);
    undoEnabled = await readWrite<bool>(rW, 'undoEnabled', undoEnabled);
    showNumbers = await readWrite<bool>(rW, 'showNumbers', showNumbers);
    forwardEnabled =
        await readWrite<bool>(rW, 'forwardEnabled', forwardEnabled);
    bestScore = await readWrite<int>(rW, 'bestScore', bestScore);
    width = 6;
    height = await readWrite<int>(rW, 'height', height);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class Engine extends ChangeNotifier {
  late Settings settings;
  late List<int> matrix;
  late List<int> colors;

  bool initialized = false;
  int nextNumber = 0;
  Engine({required this.settings});

  void init() {
        matrix = List.filled(settings.volume, 0);
    colors = List.filled(settings.volume, EnumColors.defaultColor.no);
    clearMatrix();
    initialized = true;
  }

  // List of possible moves as points (dx, dy)
  final List<Point> possibilities = const [
    Point(0, -3), // N
    Point(3, 0), // E
    Point(0, 3), // S
    Point(-3, 0), // W
    Point(2, -2), // NE
    Point(2, 2), // SE
    Point(-2, 2), // SW
    Point(-2, -2) // NW
  ];

  int coordinate(int x, int y) => (y - 1) * settings.width + (x - 1);

  void clearMatrix() {
    for (int i = 0; i < settings.volume; i++) {
      matrix[i] = 0;
      colors[i] = EnumColors.defaultColor.no;
    }
    nextNumber = 0;
    notifyListeners();
  }

  GameResultStatus onTileTap(int index) {
    final x = ((index - 1) % settings.width) + 1;
    final y = (1 + (index - 1) ~/ settings.width);

    if (isMoveValid(x, y)) {
      nextNumber++;

      if (nextNumber != -matrix[coordinate(x, y)]) {
        // If the move history differs, cancel forward history
        settings.forwardEnabled = false;
        voidForwardHistory();
      }

      matrix[coordinate(x, y)] = nextNumber;
      clearCompletedTiles();

      if (settings.hintsEnabled) {
        markPossibleMoves();
      }

      if (nextNumber > settings.bestScore) {
        settings.bestScore = nextNumber;
      }

      if (nextNumber == settings.volume) {
        updateBestScore();
        return GameResultStatus.won;
      } else if (!markPossibleMoves()) {
        return GameResultStatus.lost;
      }
    }

    notifyListeners();
    return GameResultStatus.playing;
  }

  void voidForwardHistory() {
    for (int i = 0; i < settings.volume; i++) {
      if (matrix[i] < 0) {
        matrix[i] = 0;
      }
    }
  }

  Point? findCoordinate(int num) {
    for (int y = 1; y <= settings.height; y++) {
      for (int x = 1; x <= settings.width; x++) {
        if (matrix[coordinate(x, y)] == num) {
          return Point(x, y);
        }
      }
    }
    return null;
  }

  bool markPossibleMoves() {
    final p = findCoordinate(nextNumber)!; //null for err
    bool result = false;

    for (final d in possibilities) {
      final int newX = p.x + d.x;
      final int newY = p.y + d.y;

      if (newX > 0 &&
          newY > 0 &&
          newX <= settings.width &&
          newY <= settings.height &&
          matrix[coordinate(newX, newY)] <= 0) {
        result = true;
        if (!settings.hintsEnabled) {
          break;
        }
        colors[coordinate(newX, newY)] = EnumColors.possibleMove.no;
      }
    }
    colors[coordinate(p.x, p.y)] = EnumColors.selectedTile.no;
    notifyListeners();
    return result;
  }

  void clearCompletedTiles() {
    for (int z = 0; z < settings.volume; z++) {      
      if (nextNumber > 1 && matrix[z] == nextNumber - 1) {
        colors[z] = EnumColors.previousTile.no;
      } else if (matrix[z] <= 0) {
        colors[z] = EnumColors.defaultColor.no;
      }
    }
  }

  bool isMoveValid(int x, int y) {
    if (nextNumber == 0) return true;
    final p = findCoordinate(nextNumber)!; //null for err
    if (p.x == x && p.y == y) return false;
    for (final c in possibilities) {
      final newX = p.x + c.x;
      final newY = p.y + c.y;

      if (newX <= 0 ||
          newY <= 0 ||
          newX > settings.width ||
          newY > settings.height) {
        continue;
      }
      if (matrix[coordinate(newX, newY)] <= 0 && newX == x && newY == y) {
        return true;
      }
    }
    return false;
  }

  bool undoMove() {
    if (nextNumber > 1) {
      final p = findCoordinate(nextNumber)!; //null for err
      matrix[coordinate(p.x, p.y)] = -matrix[coordinate(p.x, p.y)];
      settings.forwardEnabled = true;
      nextNumber--;
      clearCompletedTiles();
      return true;
    }
    return false;
  }

  bool redoMove() {
    final p = findCoordinate(-(nextNumber + 1));
    if (p == null || !settings.forwardEnabled) return false;

    nextNumber++;
    matrix[coordinate(p.x, p.y)] = nextNumber;
    clearCompletedTiles();
    return true;
  }

  void updateBestScore() {
    if (nextNumber > settings.bestScore) {
      settings.bestScore = nextNumber;
      settings.store(rW: write);
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}