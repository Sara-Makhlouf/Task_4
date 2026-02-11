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

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  late final AnimationController controller;
  Animation<double>? animation;

  LatLng? start;
  LatLng? end;
  double? zoomStart;
  double? zoomEnd;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<MapViewModel>();
      await vm.loadCurrentLocation();
      if (vm.waypoints.isNotEmpty) {
        cinematicMove(vm.waypoints[0]);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  void smoothMove(LatLng dest, double zoom) {
    controller.stop();

    start = mapController.camera.center;
    end = dest;

    zoomStart = mapController.camera.zoom;
    zoomEnd = zoom;

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      final lat = Tween<double>(
        begin: start!.latitude,
        end: end!.latitude,
      ).evaluate(animation!);
      final lng = Tween<double>(
        begin: start!.longitude,
        end: end!.longitude,
      ).evaluate(animation!);
      final z = Tween<double>(
        begin: zoomStart,
        end: zoomEnd,
      ).evaluate(animation!);

      mapController.move(LatLng(lat, lng), z);
    });

    controller.forward(from: 0);
  }

  Future<void> cinematicMove(LatLng dest) async {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom - 2);
    await Future.delayed(const Duration(milliseconds: 300));

    smoothMove(dest, currentZoom - 1);
    await Future.delayed(const Duration(milliseconds: 1000));

    smoothMove(dest, 16);
  }

  void fitRoute(List<LatLng> points) {
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    if (vm.routePoints.isNotEmpty && vm.cameraMode == CameraMode.followRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) fitRoute(vm.routePoints);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Map System"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search location(safita, latakia ,...)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    await vm.searchLocation(searchController.text);
                    if (vm.searchedLocation != null && mounted) {
                      if (vm.waypoints.length >= 2) {
                        vm.waypoints[1] = vm.searchedLocation!;
                      } else {
                        vm.addWaypoint(vm.searchedLocation!);
                      }
                      await vm.fetchRoute();
                      cinematicMove(vm.searchedLocation!);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: vm.clearRoute),
          IconButton(
            icon: Icon(
              vm.cameraMode == CameraMode.free ? Icons.lock_open : Icons.lock,
            ),
            onPressed: vm.toggleCameraMode,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(33.5138, 36.2765),
              initialZoom: 13,
              onTap: (tapPos, point) async {
                if (vm.waypoints.isEmpty) {
                  vm.addWaypoint(point);
                } else if (vm.waypoints.length == 1) {
                  vm.addWaypoint(point);
                } else {
                  vm.waypoints[1] = point;
                  await vm.fetchRoute();
                }
                cinematicMove(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.company.task',
              ),
              if (vm.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline<LatLng>(
                      points: vm.routePoints,
                      color: Colors.blue,
                      strokeWidth: 6,
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (vm.waypoints.isNotEmpty)
                    Marker(
                      point: vm.waypoints[0],
                      width: 40,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  if (vm.waypoints.length > 1)
                    Marker(
                      point: vm.waypoints[1],
                      width: 35,
                      height: 35,
                      child: const Icon(
                        Icons.flag,
                        color: Colors.green,
                        size: 35,
                      ),
                    ),
                  if (vm.searchedLocation != null)
                    Marker(
                      point: vm.searchedLocation!,
                      width: 35,
                      height: 35,
                      child: const Icon(
                        Icons.place,
                        color: Colors.orange,
                        size: 35,
                      ),
                    ),
                ],
              ),
            ],
          ),

          if (vm.routePoints.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alt_route, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text(
                          "${vm.distance.toStringAsFixed(2)} km",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          "${vm.duration.toStringAsFixed(0)} min",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
