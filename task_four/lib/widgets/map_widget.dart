import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AqaviaMapWidget extends StatelessWidget {
  final LatLng point;

  const AqaviaMapWidget({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(initialCenter: point, initialZoom: 15.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.map.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 60,
              height: 60,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 45,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
