import 'package:flutter/material.dart';
import 'package:task_four/screens/screen_map.dart';

void main() {
  runApp(const AqaviaApp());
}

class AqaviaApp extends StatelessWidget {
  const AqaviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapScreen(),
    );
  }
}
