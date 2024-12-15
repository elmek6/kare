import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kare/engine.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({
    required this.defaultSettings,
    super.key,
  });

  final Settings defaultSettings;

  @override
  Widget build(BuildContext context) {
    final settings = useListenable(defaultSettings);
    
    
    return AlertDialog(
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Undo / redo:'),
              Switch(
                value: settings.undoEnabled,
                onChanged: (value) {
                  settings.undoEnabled = value;
                  settings.notifyListeners();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Show numbers:'),
              Switch(
                value: settings.showNumbers,
                onChanged: (value) {
                  settings.showNumbers = value;
                  settings.notifyListeners();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Show hints:'),
              Switch(
                value: settings.hintsEnabled,
                onChanged: (value) {
                  settings.hintsEnabled = value;
                  settings.notifyListeners();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                settings.bestScore = 0;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Best score reset')),
                );
              },
              child: const Text('Reset best score'),
            ),
          ),
        ],
      ),
    );
  }
}