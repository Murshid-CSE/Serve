import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';

class ExpireOldFood {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> call() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.foodDonationsCollection)
          .where('status', isEqualTo: 'available')
          .where('expiresAt', isLessThan: Timestamp.fromDate(DateTime.now()))
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'status': 'expired'});
      }

      await batch.commit();
    } catch (e) {
      // Background operation failure is non-critical
    }
  }
}
