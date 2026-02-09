import 'package:geolocator/geolocator.dart';
import 'package:task_four/core/data/sources/source.dart';
import 'package:task_four/domain/repodo.dart';

class MapRepositoryImpl implements MapRepository {
  final LocationRemoteSource remoteSource;
  MapRepositoryImpl(this.remoteSource);

  @override
  Future<Position> getDeviceLocation() => remoteSource.getCurrentPosition();
}
