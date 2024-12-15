import 'package:flutter/material.dart';
import 'package:kare/engine.dart';
import 'package:kare/pages/defines.dart';
import 'package:kare/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final defaultSettings = Settings();
  await defaultSettings.init();
  await defaultSettings.store(rW: read);

  runApp(MyApp(
    engine: Engine(settings: defaultSettings),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.engine,
    super.key,
  });
  final Engine engine;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: HomePage(defaultEngine: engine),
    );
  }
}