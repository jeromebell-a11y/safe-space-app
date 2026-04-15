import 'package:dart_geohash/dart_geohash.dart';

class GeohashService {
  String encode(double latitude, double longitude, {int precision = 7}) {
    return GeoHasher().encode(longitude, latitude, precision: precision);
  }
}
