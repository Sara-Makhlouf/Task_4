import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:task_four/state/map_state.dart';

void main() {
  group('MapState', () {
    test('should have default values', () {
      final state = MapState();

      expect(state.selectedPoints, []);
      expect(state.distance, null);
    });

    test('copyWith should update selectedPoints', () {
      final initialState = MapState(selectedPoints: [LatLng(33.5, 36.2)]);
      final newPoints = [LatLng(34.0, 35.0)];

      final newState = initialState.copyWith(selectedPoints: newPoints);

      expect(newState.selectedPoints, newPoints);
      expect(newState.distance, initialState.distance);
    });

    test('copyWith should update distance', () {
      final initialState = MapState(distance: 10.0);

      final newState = initialState.copyWith(distance: 20.0);

      expect(newState.distance, 20.0);
      expect(newState.selectedPoints, initialState.selectedPoints);
    });

    test('copyWith without params should return same values', () {
      final initialState = MapState(
        selectedPoints: [LatLng(33.0, 36.0)],
        distance: 5.0,
      );

      final newState = initialState.copyWith();

      expect(newState.selectedPoints, initialState.selectedPoints);
      expect(newState.distance, initialState.distance);
    });
  });
}
