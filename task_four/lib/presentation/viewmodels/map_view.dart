import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum CameraMode { free, followRoute }

class MapViewModel extends ChangeNotifier {
  List<LatLng> waypoints = [];
  List<LatLng> routePoints = [];
  double distance = 0;
  double duration = 0;
  CameraMode cameraMode = CameraMode.free;
  LatLng? searchedLocation;

  Future<void> loadCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentLoc = LatLng(position.latitude, position.longitude);

      if (waypoints.isEmpty) {
        waypoints.add(currentLoc);
      } else {
        waypoints[0] = currentLoc;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading current location: $e");
    }
  }

  void addWaypoint(LatLng point) async {
    if (waypoints.isEmpty) {
      waypoints.add(point);
    } else if (waypoints.length == 1) {
      waypoints.add(point);
    } else {
      waypoints[1] = point;
    }

    routePoints.clear();

    if (waypoints.length >= 2) {
      await fetchRoute();
    }

    notifyListeners();
  }

  void clearAll() {
    waypoints.clear();
    routePoints.clear();
    distance = 0;
    duration = 0;
    searchedLocation = null;
    notifyListeners();
  }

  void toggleCameraMode() {
    cameraMode = cameraMode == CameraMode.free
        ? CameraMode.followRoute
        : CameraMode.free;
    notifyListeners();
  }

  Future<void> searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        searchedLocation = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );

        addWaypoint(searchedLocation!);
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  Future<void> fetchRoute() async {
    if (waypoints.length < 2) return;

    final coordinates = waypoints
        .map((p) => "${p.longitude},${p.latitude}")
        .join(";");

    final url = Uri.parse(
      "https://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final geometry = data['routes'][0]['geometry']['coordinates'] as List;
        routePoints = geometry
            .map<LatLng>((c) => LatLng(c[1] as double, c[0] as double))
            .toList();

        distance = (data['routes'][0]['distance'] as num) / 1000;
        duration = (data['routes'][0]['duration'] as num) / 60;

        notifyListeners();
      } else {
        debugPrint("OSRM request failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
    }
  }

  void clearRoute() {
    if (waypoints.isNotEmpty) {
      LatLng current = waypoints[0];
      waypoints = [current];
    } else {
      waypoints.clear();
    }
    routePoints.clear();
    distance = 0;
    duration = 0;
    searchedLocation = null;
    notifyListeners();
  }
}
