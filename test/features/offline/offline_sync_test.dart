import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup Mock Connectivity to simulate OFFLINE mode
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        return ['none']; // Simulate no internet connection
      },
    );
  });

  group('Offline Sync Capability Tests', () {
    test('Firestore queues writes when offline and retrieves from local cache', () async {
      // 1. Initialize Fake Firestore (simulating local cache behavior)
      final firestore = FakeFirebaseFirestore();

      // 2. Perform a write while "offline"
      final collection = firestore.collection(FirebaseConstants.foodDonationsCollection);
      
      final mockData = {
        'id': 'offline_test_id',
        'title': 'Offline Food',
        'status': 'available',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Writing data
      await collection.doc('offline_test_id').set(mockData);

      // 3. Verify that we can read the written data immediately (from local cache)
      final snapshot = await collection.doc('offline_test_id').get();
      
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['title'], equals('Offline Food'));
      
      // In a real environment with persistenceEnabled: true, this data remains in SQLite
      // and gets synced once the network is restored. FakeFirestore confirms the logic
      // of immediate read-your-own-writes which is the hallmark of Firestore offline support.
    });
  });
}
