import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/core/utils/validators.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/extensions/string_extension.dart';
import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';
import 'package:community_care_hub/features/blood/data/datasources/blood_remote_datasource.dart';

void main() {
  // ─── STRING EXTENSIONS ──────────────────────────────────────────────
  group('StringExtension Tests', () {
    test('isValidEmail returns true for valid emails', () {
      expect('test@gmail.com'.isValidEmail, isTrue);
      expect('murshid.arsath@gmail.com'.isValidEmail, isTrue);
    });

    test('isValidEmail returns false for invalid emails', () {
      expect('test'.isValidEmail, isFalse);
      expect('test@'.isValidEmail, isFalse);
      expect('test@com'.isValidEmail, isFalse);
    });

    test('isValidPhone returns true for valid 10-digit Indian numbers', () {
      expect('9876543210'.isValidPhone, isTrue);
      expect('7012345678'.isValidPhone, isTrue);
    });

    test('isValidPhone returns false for invalid phone numbers', () {
      expect('12345'.isValidPhone, isFalse);
      expect('98765432101'.isValidPhone, isFalse);
      expect('abcdefghij'.isValidPhone, isFalse);
    });

    test('capitalize capitalizes the first letter', () {
      expect('hello'.capitalize, equals('Hello'));
      expect('world'.capitalize, equals('World'));
    });

    test('initials returns correct initials', () {
      expect('Murshid Arsath'.initials, equals('MA'));
      expect('John'.initials, equals('J'));
      expect(''.initials, equals(''));
    });

    test('truncate shortens long strings', () {
      expect('Hello World'.truncate(5), equals('Hello…'));
      expect('Hi'.truncate(5), equals('Hi'));
    });
  });

  // ─── VALIDATORS ─────────────────────────────────────────────────────
  group('Validators Tests', () {
    test('validateEmail checks email constraints', () {
      expect(Validators.validateEmail(''), equals('Email is required'));
      expect(Validators.validateEmail('invalid'), equals('Please enter a valid email address'));
      expect(Validators.validateEmail('test@gmail.com'), isNull);
    });

    test('validatePassword checks length constraints', () {
      expect(Validators.validatePassword(''), equals('Password is required'));
      expect(Validators.validatePassword('123'), equals('Password must be at least 6 characters'));
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('validateConfirmPassword checks password match', () {
      expect(Validators.validateConfirmPassword('123', '456'), equals('Passwords do not match'));
      expect(Validators.validateConfirmPassword('abc123', 'abc123'), isNull);
      expect(Validators.validateConfirmPassword('', 'abc123'), equals('Please confirm your password'));
    });

    test('validateName checks name constraints', () {
      expect(Validators.validateName(''), equals('Name is required'));
      expect(Validators.validateName('A'), equals('Name must be at least 2 characters'));
      expect(Validators.validateName('John123'), equals('Name can only contain letters and spaces'));
      expect(Validators.validateName('Murshid Arsath'), isNull);
    });

    test('validatePhone checks phone constraints', () {
      expect(Validators.validatePhone(''), equals('Phone number is required'));
      expect(Validators.validatePhone('12345'), equals('Please enter a valid phone number'));
      expect(Validators.validatePhone('9876543210'), isNull);
    });

    test('validateBloodGroup accepts only valid blood groups', () {
      expect(Validators.validateBloodGroup(''), equals('Blood group is required'));
      expect(Validators.validateBloodGroup('C+'), equals('Please select a valid blood group'));
      expect(Validators.validateBloodGroup('A+'), isNull);
      expect(Validators.validateBloodGroup('AB-'), isNull);
      expect(Validators.validateBloodGroup('O-'), isNull);
    });

    test('validateLocation checks coordinate validity', () {
      expect(Validators.validateLocation(null, null), equals('Location is required'));
      expect(Validators.validateLocation(91.0, 0.0), equals('Invalid location coordinates'));
      expect(Validators.validateLocation(0.0, 181.0), equals('Invalid location coordinates'));
      expect(Validators.validateLocation(13.0, 80.0), isNull);
    });

    test('isValidLatitude and isValidLongitude boundary checks', () {
      expect(Validators.isValidLatitude(-90), isTrue);
      expect(Validators.isValidLatitude(90), isTrue);
      expect(Validators.isValidLatitude(90.1), isFalse);
      expect(Validators.isValidLongitude(-180), isTrue);
      expect(Validators.isValidLongitude(180), isTrue);
      expect(Validators.isValidLongitude(180.1), isFalse);
    });

    test('validateTitle checks title length constraints', () {
      expect(Validators.validateTitle(''), equals('Title is required'));
      expect(Validators.validateTitle('AB'), equals('Title must be at least 3 characters'));
      expect(Validators.validateTitle('A' * 101), equals('Title is too long (max 100 characters)'));
      expect(Validators.validateTitle('Valid Title'), isNull);
    });

    test('validateDescription checks description constraints', () {
      expect(Validators.validateDescription(''), equals('Description is required'));
      expect(Validators.validateDescription('Short'), equals('Please provide a more detailed description'));
      expect(Validators.validateDescription('A' * 501), equals('Description is too long (max 500 characters)'));
      expect(Validators.validateDescription('A valid description that is long enough.'), isNull);
    });

    test('validateUnitsNeeded checks unit range', () {
      expect(Validators.validateUnitsNeeded(''), equals('Units needed is required'));
      expect(Validators.validateUnitsNeeded('0'), equals('Please enter a valid number of units'));
      expect(Validators.validateUnitsNeeded('21'), equals('Maximum 20 units can be requested'));
      expect(Validators.validateUnitsNeeded('5'), isNull);
    });
  });

  // ─── GEO UTILS ──────────────────────────────────────────────────────
  group('GeoUtils Tests', () {
    test('calculateDistance returns correct Haversine distance', () {
      // Chennai (13.08, 80.27) to Bangalore (12.97, 77.59) ≈ 290 km
      final distance = GeoUtils.calculateDistance(13.08, 80.27, 12.97, 77.59);
      expect(distance, greaterThan(280));
      expect(distance, lessThan(300));
    });

    test('calculateDistance returns 0 for same point', () {
      final distance = GeoUtils.calculateDistance(13.08, 80.27, 13.08, 80.27);
      expect(distance, equals(0.0));
    });

    test('encodeGeohash produces correct length', () {
      final hash = GeoUtils.encodeGeohash(13.08, 80.27, precision: 7);
      expect(hash.length, equals(7));
    });

    test('encodeGeohash is deterministic', () {
      final hash1 = GeoUtils.encodeGeohash(13.08, 80.27, precision: 7);
      final hash2 = GeoUtils.encodeGeohash(13.08, 80.27, precision: 7);
      expect(hash1, equals(hash2));
    });

    test('encodeGeohash produces different hashes for different locations', () {
      final chennai = GeoUtils.encodeGeohash(13.08, 80.27, precision: 7);
      final mumbai = GeoUtils.encodeGeohash(19.07, 72.87, precision: 7);
      expect(chennai, isNot(equals(mumbai)));
    });

    test('nearby points share geohash prefix', () {
      // Two points ~100m apart should share at least a 5-char prefix
      final hash1 = GeoUtils.encodeGeohash(13.0827, 80.2707, precision: 7);
      final hash2 = GeoUtils.encodeGeohash(13.0828, 80.2708, precision: 7);
      expect(hash1.substring(0, 5), equals(hash2.substring(0, 5)));
    });

    test('geohashPrecisionForRadius returns correct precision levels', () {
      expect(GeoUtils.geohashPrecisionForRadius(0.1), equals(7));
      expect(GeoUtils.geohashPrecisionForRadius(1.0), equals(6));
      expect(GeoUtils.geohashPrecisionForRadius(5.0), equals(5));
      expect(GeoUtils.geohashPrecisionForRadius(25.0), equals(4));
      expect(GeoUtils.geohashPrecisionForRadius(100.0), equals(3));
    });

    test('formatDistance formats correctly', () {
      expect(GeoUtils.formatDistance(0.5), equals('500 m'));
      expect(GeoUtils.formatDistance(3.45), equals('3.5 km'));
      expect(GeoUtils.formatDistance(25.0), equals('25 km'));
    });

    test('isWithinIndia returns correct results', () {
      // Chennai — inside India
      expect(GeoUtils.isWithinIndia(13.08, 80.27), isTrue);
      // London — outside India
      expect(GeoUtils.isWithinIndia(51.5, -0.12), isFalse);
      // Edge case — southernmost India tip
      expect(GeoUtils.isWithinIndia(8.0, 77.0), isTrue);
    });

    test('filterByDistance filters correctly', () {
      final items = [
        {'lat': 13.08, 'lng': 80.27}, // Same point
        {'lat': 13.10, 'lng': 80.30}, // ~4 km away
        {'lat': 14.00, 'lng': 81.00}, // ~120 km away
      ];

      final filtered = GeoUtils.filterByDistance<Map<String, double>>(
        items: items,
        centerLat: 13.08,
        centerLng: 80.27,
        radiusKm: 10.0,
        getLatitude: (item) => item['lat']!,
        getLongitude: (item) => item['lng']!,
      );

      expect(filtered.length, equals(2)); // Only the first two within 10km
    });

    test('sortByDistance sorts closest first', () {
      final items = [
        {'lat': 14.00, 'lng': 81.00}, // Far
        {'lat': 13.08, 'lng': 80.27}, // Same point
        {'lat': 13.10, 'lng': 80.30}, // Near
      ];

      final sorted = GeoUtils.sortByDistance<Map<String, double>>(
        items: items,
        centerLat: 13.08,
        centerLng: 80.27,
        getLatitude: (item) => item['lat']!,
        getLongitude: (item) => item['lng']!,
      );

      expect(sorted.first['lat'], equals(13.08)); // Closest first
      expect(sorted.last['lat'], equals(14.00)); // Farthest last
    });
  });

  // ─── USER ENTITY ────────────────────────────────────────────────────
  group('UserEntity Tests', () {
    final now = DateTime(2025, 1, 15, 12, 0, 0);

    test('fromMap correctly parses a complete user document', () {
      final map = {
        'uid': 'test-uid',
        'name': 'Murshid',
        'email': 'test@gmail.com',
        'phone': '9876543210',
        'photoUrl': 'https://example.com/photo.jpg',
        'role': 'both',
        'bloodGroup': 'O+',
        'isBloodDonorActive': true,
        'lastBloodDonationDate': Timestamp.fromDate(DateTime(2024, 10, 1)),
        'location': {'lat': 13.08, 'lng': 80.27, 'geohash': 'tdr1w3e'},
        'impactScore': 42.5,
        'reliabilityScore': 95.0,
        'totalFoodDonations': 10,
        'totalBloodDonations': 3,
        'totalVolunteerTasks': 5,
        'fcmToken': 'test-token',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final user = UserEntity.fromMap(map);

      expect(user.uid, equals('test-uid'));
      expect(user.name, equals('Murshid'));
      expect(user.email, equals('test@gmail.com'));
      expect(user.role, equals('both'));
      expect(user.bloodGroup, equals('O+'));
      expect(user.isBloodDonorActive, isTrue);
      expect(user.latitude, equals(13.08));
      expect(user.longitude, equals(80.27));
      expect(user.geohash, equals('tdr1w3e'));
      expect(user.impactScore, equals(42.5));
      expect(user.totalFoodDonations, equals(10));
      expect(user.hasLocation, isTrue);
    });

    test('fromMap handles missing optional fields gracefully', () {
      final map = {
        'uid': 'test-uid',
        'name': 'Test',
        'email': 'test@test.com',
        'role': 'donor',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final user = UserEntity.fromMap(map);

      expect(user.phone, equals(''));
      expect(user.photoUrl, isNull);
      expect(user.bloodGroup, isNull);
      expect(user.isBloodDonorActive, isFalse);
      expect(user.latitude, equals(0.0));
      expect(user.impactScore, equals(0.0));
      expect(user.hasLocation, isFalse);
    });

    test('role helper getters return correct values', () {
      final admin = UserEntity(
        uid: 'a', name: 'Admin', email: 'a@a.com', phone: '', role: 'admin',
        createdAt: now, updatedAt: now,
      );
      final donor = UserEntity(
        uid: 'b', name: 'Donor', email: 'b@b.com', phone: '', role: 'donor',
        createdAt: now, updatedAt: now,
      );
      final volunteer = UserEntity(
        uid: 'c', name: 'Vol', email: 'c@c.com', phone: '', role: 'volunteer',
        createdAt: now, updatedAt: now,
      );
      final both = UserEntity(
        uid: 'd', name: 'Both', email: 'd@d.com', phone: '', role: 'both',
        createdAt: now, updatedAt: now,
      );

      expect(admin.isAdmin, isTrue);
      expect(admin.isDonor, isFalse);
      expect(donor.isDonor, isTrue);
      expect(donor.isVolunteer, isFalse);
      expect(volunteer.isVolunteer, isTrue);
      expect(both.isDonor, isTrue);
      expect(both.isVolunteer, isTrue);
    });

    test('canDonateBlood respects 90-day cooldown', () {
      // Active donor, donated 60 days ago — cannot donate
      final recentDonor = UserEntity(
        uid: 'x', name: 'X', email: 'x@x.com', phone: '', role: 'donor',
        isBloodDonorActive: true,
        lastBloodDonationDate: DateTime.now().subtract(const Duration(days: 60)),
        createdAt: now, updatedAt: now,
      );
      expect(recentDonor.canDonateBlood, isFalse);

      // Active donor, donated 100 days ago — can donate
      final oldDonor = UserEntity(
        uid: 'y', name: 'Y', email: 'y@y.com', phone: '', role: 'donor',
        isBloodDonorActive: true,
        lastBloodDonationDate: DateTime.now().subtract(const Duration(days: 100)),
        createdAt: now, updatedAt: now,
      );
      expect(oldDonor.canDonateBlood, isTrue);

      // Inactive donor — cannot donate
      final inactiveDonor = UserEntity(
        uid: 'z', name: 'Z', email: 'z@z.com', phone: '', role: 'donor',
        isBloodDonorActive: false,
        createdAt: now, updatedAt: now,
      );
      expect(inactiveDonor.canDonateBlood, isFalse);

      // Active, never donated — can donate
      final newDonor = UserEntity(
        uid: 'w', name: 'W', email: 'w@w.com', phone: '', role: 'donor',
        isBloodDonorActive: true,
        createdAt: now, updatedAt: now,
      );
      expect(newDonor.canDonateBlood, isTrue);
    });

    test('toMap produces valid Timestamps for createdAt and updatedAt', () {
      final user = UserEntity(
        uid: 'test', name: 'Test', email: 'test@test.com', phone: '',
        role: 'donor', createdAt: now, updatedAt: now,
      );

      final map = user.toMap();

      expect(map['createdAt'], isA<Timestamp>());
      expect(map['updatedAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), equals(now));
    });

    test('copyWith preserves unmodified fields', () {
      final user = UserEntity(
        uid: 'test', name: 'Original', email: 'test@test.com', phone: '123',
        role: 'donor', impactScore: 50.0, createdAt: now, updatedAt: now,
      );

      final updated = user.copyWith(name: 'Updated');

      expect(updated.name, equals('Updated'));
      expect(updated.uid, equals('test'));
      expect(updated.email, equals('test@test.com'));
      expect(updated.impactScore, equals(50.0));
    });
  });

  // ─── FOOD DONATION ENTITY ──────────────────────────────────────────
  group('FoodDonationEntity Tests', () {
    test('isExpired returns true for past expiry', () {
      final expired = FoodDonationEntity(
        id: '1', donorId: 'd1', donorName: 'Donor', donorPhone: '123',
        title: 'Test', description: 'Test food', category: 'cooked',
        quantity: '5 servings', status: 'available', pickupAddress: 'Chennai',
        latitude: 13.08, longitude: 80.27, geohash: 'tdr1w3e',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      );
      expect(expired.isExpired, isTrue);
      expect(expired.isAvailable, isFalse);
    });

    test('isAvailable returns true for non-expired available items', () {
      final available = FoodDonationEntity(
        id: '2', donorId: 'd1', donorName: 'Donor', donorPhone: '123',
        title: 'Test', description: 'Test food', category: 'cooked',
        quantity: '5 servings', status: 'available', pickupAddress: 'Chennai',
        latitude: 13.08, longitude: 80.27, geohash: 'tdr1w3e',
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
        createdAt: DateTime.now(),
      );
      expect(available.isAvailable, isTrue);
      expect(available.isExpired, isFalse);
    });

    test('status helpers return correct values', () {
      final accepted = FoodDonationEntity(
        id: '3', donorId: 'd1', donorName: 'Donor', donorPhone: '123',
        title: 'Test', description: 'Test food', category: 'raw',
        quantity: '2 kg', status: 'accepted', pickupAddress: 'Chennai',
        latitude: 13.08, longitude: 80.27, geohash: 'tdr1w3e',
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
        createdAt: DateTime.now(),
      );
      expect(accepted.isAccepted, isTrue);
      expect(accepted.isAvailable, isFalse);
      expect(accepted.isCollected, isFalse);
    });
  });

  // ─── BLOOD GROUP COMPATIBILITY ─────────────────────────────────────
  group('Blood Group Compatibility Tests', () {
    test('O- is universal donor (can donate to all)', () {
      // O- should appear in the compatible list for every blood group
      BloodRemoteDataSource.compatibilityMap.forEach((group, compatible) {
        expect(compatible, contains('O-'),
            reason: '$group should accept O- as universal donor');
      });
    });

    test('AB+ is universal recipient (can receive from all)', () {
      final abPlusCompatible = BloodRemoteDataSource.compatibilityMap['AB+']!;
      expect(abPlusCompatible.length, equals(8));
    });

    test('O+ can only receive from O+ and O-', () {
      final oPlusCompatible = BloodRemoteDataSource.compatibilityMap['O+']!;
      expect(oPlusCompatible, equals(['O+', 'O-']));
    });

    test('All 8 standard blood groups are present', () {
      const expectedGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      for (final group in expectedGroups) {
        expect(BloodRemoteDataSource.compatibilityMap.containsKey(group), isTrue,
            reason: 'Missing blood group: $group');
      }
      expect(BloodRemoteDataSource.compatibilityMap.length, equals(8));
    });

    test('Rh-negative can only receive Rh-negative', () {
      // A- can only receive from A- and O-
      final aMinusCompatible = BloodRemoteDataSource.compatibilityMap['A-']!;
      for (final donor in aMinusCompatible) {
        expect(donor.endsWith('-'), isTrue,
            reason: 'Rh-negative recipient A- should not receive Rh-positive $donor');
      }
    });
  });
}
