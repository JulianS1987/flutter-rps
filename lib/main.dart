import 'package:flutter/material.dart';
import 'package:rock_paper_scissors/widget/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rock Paper Scissors',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 66, 183, 58)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
