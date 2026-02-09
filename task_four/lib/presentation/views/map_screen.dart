import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_view.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final xx = context.read<MapViewModel>();
      await xx.loadCurrentLocation();
      if (xx.currentLoc != null) {
        mapController.move(xx.currentLoc!, 15.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(" Map System"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search (e.g. Damascus, Syria)",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    await vm.searchArea(searchController.text);
                    if (vm.targetLoc != null) {
                      mapController.move(vm.targetLoc!, 14.0);
                    }
                  },
                ),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onSubmitted: (val) async {
                await vm.searchArea(val);
                if (vm.targetLoc != null)
                  mapController.move(vm.targetLoc!, 14.0);
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(33.5138, 36.2765),
              initialZoom: 13.0,
              onTap: (tapPos, point) {
                vm.targetLoc = point;
                vm.calculateDistance();
                setState(() {});
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.aqavia.task_four',
              ),
              MarkerLayer(
                markers: [
                  if (vm.currentLoc != null)
                    Marker(
                      point: vm.currentLoc!,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  if (vm.targetLoc != null)
                    Marker(
                      point: vm.targetLoc!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (vm.distance > 0)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Distance to Target: ${vm.distance.toStringAsFixed(2)} KM",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
