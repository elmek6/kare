import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kare/engine.dart';
import 'package:kare/pages/defines.dart';
import 'package:kare/pages/help_page.dart';
import 'package:kare/pages/settings_page.dart';

class HomePage extends HookWidget {
  const HomePage({
    required this.defaultEngine,
    super.key,
  });

  final Engine defaultEngine;

  @override
  Widget build(BuildContext context) {
    final engine = useListenable(defaultEngine);

    Future<void> onTileTap(int index) async {
      final result = engine.onTileTap(index);

      if (result == GameResultStatus.won) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('! YOU WON !')),
        );
      } else if (result == GameResultStatus.lost) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other possible move')),
        );
      }
    }

    void showHelpDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              child: const HelpPage(),
            ),
          );
        },
      );
    }

    Future<void> showSettingsDialog() async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SettingsPage(
            defaultSettings: engine.settings,
          );
        },
      );
      await engine.settings.store(rW: write);
      engine.clearCompletedTiles();
      engine.markPossibleMoves();
      engine.notifyListeners();
    }

    void undoMove() {
      if (engine.undoMove()) {
        engine.markPossibleMoves();
      }
    }

    void redoMove() {
      if (engine.redoMove()) {
        engine.markPossibleMoves();
      }
    }

    void resetGame() {
      engine.clearMatrix();
    }

    useEffect(() {
      engine.init();
      return () {
        // bannerAd.value?.dispose();
      };
      // bannerAd
    }, []);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton.filled(
                    icon: const Icon(Icons.help),
                    onPressed: showHelpDialog,
                  ),
                  const Spacer(),
                  const Text(
                    '1D2D',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      const Text(
                        'BEST',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        engine.settings.bestScore.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Control Buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.outlined(
                    icon: const Icon(Icons.settings),
                    iconSize: 28,
                    onPressed: showSettingsDialog,
                  ),
                  if (engine.settings.undoEnabled) ...[
                    IconButton.filled(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: undoMove,
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: redoMove,
                    ),
                  ],
                  IconButton.outlined(
                    icon: const Icon(Icons.refresh),
                    iconSize: 28,
                    onPressed: resetGame,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Game Grid
            Expanded(
              child: engine.initialized == false
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                      crossAxisCount: engine.settings.width,
                      children: List.generate(engine.settings.volume, (index) {
                        final pos = engine.matrix[index];
                        final color = EnumColors.values[engine.colors[index]].getColor();
                        final isSelected = pos == engine.nextNumber;
                        return GestureDetector(
                          onTap: () {
                            onTileTap(index + 1);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color:  Colors.white,
                                width:  1,
                              ),
                            ),
                            child: Center(
                              child: engine.settings.showNumbers && pos > 0
                                  ? Text(
                                      pos.toString(),
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected ? Colors.black87 : Colors.white,
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                        );
                      }),
                    )
,
            ),
          ],
        ),
      ),
    );
  }
}