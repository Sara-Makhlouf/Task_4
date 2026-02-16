import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:task_four/presentation/viewmodels/map_view.dart';

void main() {
  late MapViewModel viewModel;

  setUp(() {
    viewModel = MapViewModel();
  });

  test('addWaypoint adds points correctly', () async {
    final p1 = LatLng(33.5, 36.2);
    final p2 = LatLng(34.0, 36.5);

    viewModel.addWaypoint(p1);
    expect(viewModel.waypoints.length, 1);
    expect(viewModel.waypoints.first, p1);

    viewModel.addWaypoint(p2);
    expect(viewModel.waypoints.length, 2);
    expect(viewModel.waypoints[1], p2);
  });

  test('toggleCameraMode switches between free and followRoute', () {
    expect(viewModel.cameraMode, CameraMode.free);
    viewModel.toggleCameraMode();
    expect(viewModel.cameraMode, CameraMode.followRoute);
    viewModel.toggleCameraMode();
    expect(viewModel.cameraMode, CameraMode.free);
  });

  test('clearAll resets state', () {
    viewModel.waypoints.add(LatLng(33.5, 36.2));
    viewModel.routePoints.add(LatLng(34.0, 36.0));
    viewModel.distance = 10;
    viewModel.duration = 5;
    viewModel.searchedLocation = LatLng(34, 36);

    viewModel.clearAll();

    expect(viewModel.waypoints, []);
    expect(viewModel.routePoints, []);
    expect(viewModel.distance, 0);
    expect(viewModel.duration, 0);
    expect(viewModel.searchedLocation, null);
  });

  test('clearRoute keeps first waypoint if exists', () {
    final first = LatLng(33.5, 36.2);
    viewModel.waypoints.add(first);
    viewModel.waypoints.add(LatLng(34, 36));
    viewModel.routePoints.add(LatLng(34.1, 36.1));
    viewModel.distance = 12;
    viewModel.duration = 10;

    viewModel.clearRoute();

    expect(viewModel.waypoints, [first]);
    expect(viewModel.routePoints, []);
    expect(viewModel.distance, 0);
    expect(viewModel.duration, 0);
  });
}
