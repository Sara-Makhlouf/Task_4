import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/viewmodels/map_view.dart';
import 'presentation/views/map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AqaviaApp());
}

class AqaviaApp extends StatelessWidget {
  const AqaviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MapViewModel()..loadCurrentLocation(),
        ),
      ],
      child: MaterialApp(
        title: 'Map System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MapScreen(),
      ),
    );
  }
}
