import 'package:mockito/annotations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([GeolocatorPlatform, http.Client, GeocodingPlatform])
void main() {}
