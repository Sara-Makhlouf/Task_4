import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapViewModel extends ChangeNotifier {
  LatLng? currentLoc;
  LatLng? startLoc;
  LatLng? targetLoc;
  double distance = 0.0;
  List<LatLng> routePoints = [];

  Future<void> loadCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentLoc = LatLng(position.latitude, position.longitude);
    startLoc = currentLoc;
    notifyListeners();
  }

  Future<void> fetchRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List coords = data['routes'][0]['geometry']['coordinates'];
        routePoints = coords
            .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();

        distance = data['routes'][0]['distance'] / 1000.0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("خطأ في جلب المسار: $e");
    }
  }

  Future<void> searchArea(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        targetLoc = LatLng(locations.first.latitude, locations.first.longitude);
        startLoc = currentLoc;
        if (startLoc != null) await fetchRoute(startLoc!, targetLoc!);
      }
    } catch (e) {
      debugPrint("خطأ في البحث: $e");
    }
  }

  void setManualPoint(LatLng point) {
    if (startLoc == null || (startLoc != null && targetLoc != null)) {
      startLoc = point;
      targetLoc = null;
      routePoints = [];
      distance = 0;
    } else {
      targetLoc = point;
      fetchRoute(startLoc!, targetLoc!);
    }
    notifyListeners();
  }
}
