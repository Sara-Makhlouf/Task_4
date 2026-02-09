// map_state.dart
import 'package:latlong2/latlong.dart';

class MapState {
  final List<LatLng> selectedPoints;
  final double? distance;

  MapState({this.selectedPoints = const [], this.distance});

  MapState copyWith({List<LatLng>? selectedPoints, double? distance}) {
    return MapState(
      selectedPoints: selectedPoints ?? this.selectedPoints,
      distance: distance ?? this.distance,
    );
  }
}
