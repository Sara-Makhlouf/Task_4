import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/viewmodels/map_view.dart';
import 'presentation/views/map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const APP());
}

class APP extends StatelessWidget {
  const APP({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final vm = MapViewModel();
            Future.microtask(() => vm.loadCurrentLocation());
            return vm;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Senior Map App',
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
