import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:task_four/presentation/viewmodels/map_view.dart';
import 'package:task_four/presentation/views/map_screen.dart';

import 'mocks/map_view_model_mock.mocks.dart';

void main() {
  late MockMapViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockMapViewModel();

    when(mockViewModel.waypoints).thenReturn([]);
    when(mockViewModel.routePoints).thenReturn([]);
    when(mockViewModel.cameraMode).thenReturn(CameraMode.free);
    when(mockViewModel.distance).thenReturn(0.0);
    when(mockViewModel.duration).thenReturn(0.0);
    when(mockViewModel.searchedLocation).thenReturn(null);

    when(mockViewModel.loadCurrentLocation()).thenAnswer((_) async {});
    when(mockViewModel.searchLocation(any)).thenAnswer((_) async {});
    when(mockViewModel.fetchRoute()).thenAnswer((_) async {});
    when(mockViewModel.addWaypoint(any)).thenReturn(null);
    when(mockViewModel.clearRoute()).thenReturn(null);
    when(mockViewModel.toggleCameraMode()).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<MapViewModel>.value(
      value: mockViewModel,
      child: const MaterialApp(home: MapScreen()),
    );
  }

  testWidgets('MapScreen builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(MapScreen), findsOneWidget);
    expect(find.text('Map System'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('Search button calls searchLocation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Damascus');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    verify(mockViewModel.searchLocation('Damascus')).called(1);
  });

  testWidgets('Camera mode toggle button calls toggleCameraMode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.lock_open));
    await tester.pump();

    verify(mockViewModel.toggleCameraMode()).called(1);
  });

  testWidgets('Clear button calls clearRoute', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    verify(mockViewModel.clearRoute()).called(1);
  });
}
