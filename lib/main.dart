import 'package:flutter/material.dart';

void main() {
  runApp(const NoteAIApp());
}

class NoteAIApp extends StatelessWidget {
  const NoteAIApp({super.key});

  @override
  Widget build(BuildContext contexet) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}
