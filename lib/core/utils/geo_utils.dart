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

  /// Base32 alphabet used in geohashing
  static const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Geohash precision for a given search radius
  static int geohashPrecisionForRadius(double radiusKm) {
    if (radiusKm <= 0.153) return 7;
    if (radiusKm <= 1.2) return 6;
    if (radiusKm <= 5.0) return 5;
    if (radiusKm <= 39.0) return 4;
    if (radiusKm <= 156.0) return 3;
    if (radiusKm <= 1250.0) return 2;
    return 1;
  }

  /// Decode a geohash string back to its bounding box
  /// Returns [minLat, maxLat, minLng, maxLng]
  static List<double> _decodeGeohashBounds(String geohash) {
    double minLat = -90.0, maxLat = 90.0;
    double minLng = -180.0, maxLng = 180.0;
    bool isEven = true;

    for (int i = 0; i < geohash.length; i++) {
      final ch = _base32.indexOf(geohash[i]);
      for (int bit = 4; bit >= 0; bit--) {
        if (isEven) {
          final mid = (minLng + maxLng) / 2;
          if ((ch >> bit) & 1 == 1) {
            minLng = mid;
          } else {
            maxLng = mid;
          }
        } else {
          final mid = (minLat + maxLat) / 2;
          if ((ch >> bit) & 1 == 1) {
            minLat = mid;
          } else {
            maxLat = mid;
          }
        }
        isEven = !isEven;
      }
    }
    return [minLat, maxLat, minLng, maxLng];
  }

  /// Get all 8 neighboring geohash cells plus the center cell (9 total)
  /// Uses coordinate arithmetic: decode center to lat/lng bounds, 
  /// then step by the cell size in each direction and re-encode
  static List<String> getGeohashNeighbors(String geohash) {
    final bounds = _decodeGeohashBounds(geohash);
    final latStep = bounds[1] - bounds[0]; // cell height
    final lngStep = bounds[3] - bounds[2]; // cell width
    final centerLat = (bounds[0] + bounds[1]) / 2;
    final centerLng = (bounds[2] + bounds[3]) / 2;
    final precision = geohash.length;

    final neighbors = <String>{};
    for (int dLat = -1; dLat <= 1; dLat++) {
      for (int dLng = -1; dLng <= 1; dLng++) {
        final lat = centerLat + dLat * latStep;
        final lng = centerLng + dLng * lngStep;
        // Clamp to valid ranges
        if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          neighbors.add(encodeGeohash(lat, lng, precision: precision));
        }
      }
    }

    return neighbors.toList();
  }



  /// Get optimized query ranges for nearby geohash queries.
  /// Returns a list of [lower, upper] pairs for Firestore range queries.
  /// Merges contiguous ranges to minimize the number of queries.
  static List<List<String>> getGeohashQueryRanges(double lat, double lng, double radiusKm) {
    final precision = geohashPrecisionForRadius(radiusKm);
    final centerGeohash = encodeGeohash(lat, lng, precision: precision);
    final neighbors = getGeohashNeighbors(centerGeohash);

    // Sort and deduplicate
    final sorted = neighbors.toSet().toList()..sort();

    // Merge contiguous ranges
    final List<List<String>> ranges = [];
    String rangeStart = sorted[0];
    String rangeEnd = sorted[0];

    for (int i = 1; i < sorted.length; i++) {
      // Check if this geohash is contiguous with the previous one
      if (_areContiguous(rangeEnd, sorted[i])) {
        rangeEnd = sorted[i];
      } else {
        ranges.add([rangeStart, '$rangeEnd\uffff']);
        rangeStart = sorted[i];
        rangeEnd = sorted[i];
      }
    }
    ranges.add([rangeStart, '$rangeEnd\uffff']);

    return ranges;
  }

  /// Check if two geohashes are contiguous (differ by 1 in the last character)
  static bool _areContiguous(String a, String b) {
    if (a.length != b.length) return false;
    if (a.substring(0, a.length - 1) != b.substring(0, b.length - 1)) return false;
    final idxA = _base32.indexOf(a[a.length - 1]);
    final idxB = _base32.indexOf(b[b.length - 1]);
    return (idxB - idxA) == 1;
  }

  /// @deprecated Use getGeohashQueryRanges instead
  /// Get geohash neighbors for a given geohash (legacy single-range)
  static List<String> getGeohashRange(String geohash) {
    final lastChar = geohash[geohash.length - 1];
    final prefix = geohash.substring(0, geohash.length - 1);

    final index = _base32.indexOf(lastChar);

    final lower = index > 0
        ? '$prefix${_base32[index - 1]}'
        : geohash;
    final upper = index < _base32.length - 1
        ? '$prefix${_base32[index + 1]}'
        : geohash;

    return [lower, upper];
  }

  /// @deprecated Use getGeohashQueryRanges instead
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

  /// Get the current device position with permission handling and fallback strategies
  static Future<Position> getCurrentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Try last known position before giving up
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      throw Exception('Location services are disabled on your device.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable in Settings.');
    }

    // 1. Try high accuracy with timeout
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      // 2. Fallback to last known position
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;

      // 3. Fallback to balanced/medium accuracy
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        throw Exception('Unable to acquire GPS location. Please check signal: $e');
      }
    }
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
