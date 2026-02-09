import 'package:geolocator/geolocator.dart';

class LocationRemoteSource {
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
