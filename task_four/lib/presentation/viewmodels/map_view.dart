import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapViewModel extends ChangeNotifier {
  LatLng? currentLoc;
  LatLng? targetLoc;
  double distance = 0.0;
  bool isLoading = false;

  Future<void> loadCurrentLocation() async {
    isLoading = true;
    notifyListeners();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      currentLoc = LatLng(position.latitude, position.longitude);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> searchArea(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        targetLoc = LatLng(locations.first.latitude, locations.first.longitude);
        calculateDistance();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error in Dearch: $e");
    }
  }

  void calculateDistance() {
    if (currentLoc != null && targetLoc != null) {
      distance =
          Geolocator.distanceBetween(
            currentLoc!.latitude,
            currentLoc!.longitude,
            targetLoc!.latitude,
            targetLoc!.longitude,
          ) /
          1000;
    }
  }
}
