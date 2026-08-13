const admin = require('firebase-admin');

// Point to Firestore emulator
process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';

admin.initializeApp({
  projectId: 'community-care-hub'
});

const db = admin.firestore();

async function runTest() {
  console.log("1. Adding food donation...");
  const docRef = db.collection('food_donations').doc('test-donation-123');
  await docRef.set({
    title: 'Test food',
    imagePublicId: 'community-care-hub/food/test_abc_123',
    expiresAt: admin.firestore.Timestamp.fromDate(new Date())
  });

  console.log("2. Updating food donation (replacing image)...");
  await docRef.update({
    imagePublicId: 'community-care-hub/food/test_new_456'
  });

  console.log("3. Deleting food donation...");
  await docRef.delete();

  console.log("4. User profile update test...");
  const userRef = db.collection('users').doc('test-user-123');
  await userRef.set({
    name: 'Test User',
    imagePublicId: 'community-care-hub/profiles/old_avatar'
  });

  await userRef.update({
    imagePublicId: 'community-care-hub/profiles/new_avatar'
  });

  console.log("All operations sent to emulator. Wait a few seconds and inspect emulator logs!");
}

runTest().catch(console.error);
