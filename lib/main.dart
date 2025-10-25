import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'myhomepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MergeMyPDF',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red[400]!),
      ),
      home: const MyHomePage(),
    );
  }
}