import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeoUtils {
  GeoUtils._();

  static const double _earthRadiusKm = 6371.0;

  /// Calculate distance between two coordinates in kilometers using Haversine formula
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
    return '${distanceKm.round()} km';
  }

  /// Generate a geohash for given coordinates
  /// Precision levels: 1=5000km, 2=1250km, 3=156km, 4=39km, 5=5km, 6=1.2km, 7=153m
  static String encodeGeohash(double latitude, double longitude, {int precision = 7}) {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

    double minLat = -90.0, maxLat = 90.0;
    double minLng = -180.0, maxLng = 180.0;

    final buffer = StringBuffer();
    var isEven = true;
    var bit = 0;
    var ch = 0;

    while (buffer.length < precision) {
      if (isEven) {
        final mid = (minLng + maxLng) / 2;
        if (longitude >= mid) {
          ch |= (1 << (4 - bit));
          minLng = mid;
        } else {
          maxLng = mid;
        }
      } else {
        final mid = (minLat + maxLat) / 2;
        if (latitude >= mid) {
          ch |= (1 << (4 - bit));
          minLat = mid;
        } else {
          maxLat = mid;
        }
      }

      isEven = !isEven;
      bit++;

      if (bit == 5) {
        buffer.write(base32[ch]);
        bit = 0;
        ch = 0;
      }
    }

    return buffer.toString();
  }

  /// Get geohash prefix for a given radius
  /// Used for Firestore geospatial queries
  static int geohashPrecisionForRadius(double radiusKm) {
    if (radiusKm <= 0.153) return 7;
    if (radiusKm <= 1.2) return 6;
    if (radiusKm <= 5.0) return 5;
    if (radiusKm <= 39.0) return 4;
    if (radiusKm <= 156.0) return 3;
    if (radiusKm <= 1250.0) return 2;
    return 1;
  }

  /// Get geohash neighbors for a given geohash
  /// Returns list of geohash prefixes to query for nearby results
  static List<String> getGeohashRange(String geohash) {
    final lastChar = geohash[geohash.length - 1];
    final prefix = geohash.substring(0, geohash.length - 1);

    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    final index = base32.indexOf(lastChar);

    final lower = index > 0
        ? '$prefix${base32[index - 1]}'
        : geohash;
    final upper = index < base32.length - 1
        ? '$prefix${base32[index + 1]}'
        : geohash;

    return [lower, upper];
  }

  /// Get geohash prefix for nearby queries based on search radius
  static String getGeohashPrefix(double lat, double lng, double radiusKm) {
    final precision = geohashPrecisionForRadius(radiusKm);
    final fullGeohash = encodeGeohash(lat, lng, precision: precision);
    return fullGeohash;
  }

  /// Filter results by actual distance (post-geohash filter)
  static List<T> filterByDistance<T>({
    required List<T> items,
    required double centerLat,
    required double centerLng,
    required double radiusKm,
    required double Function(T) getLatitude,
    required double Function(T) getLongitude,
  }) {
    return items.where((item) {
      final distance = calculateDistance(
        centerLat,
        centerLng,
        getLatitude(item),
        getLongitude(item),
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Sort items by distance from a center point
  static List<T> sortByDistance<T>({
    required List<T> items,
    required double centerLat,
    required double centerLng,
    required double Function(T) getLatitude,
    required double Function(T) getLongitude,
  }) {
    return List<T>.from(items)..sort((a, b) {
      final distA = calculateDistance(
        centerLat, centerLng, getLatitude(a), getLongitude(a),
      );
      final distB = calculateDistance(
        centerLat, centerLng, getLatitude(b), getLongitude(b),
      );
      return distA.compareTo(distB);
    });
  }

  /// Check if coordinates are within India (approximate bounding box)
  static bool isWithinIndia(double lat, double lng) {
    return lat >= 6.0 && lat <= 37.0 && lng >= 68.0 && lng <= 97.5;
  }

  /// Get the current device position with permission handling
  static Future<Position> getCurrentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Reverse-geocode coordinates to a human-readable address
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.street, p.subLocality, p.locality, p.administrativeArea]
            .where((s) => s != null && s.isNotEmpty)
            .toList();
        return parts.join(', ');
      }
    } catch (_) {}
    return '';
  }
}
