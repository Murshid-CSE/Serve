import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { logger } from "firebase-functions";

export const cleanupExpiredDonations = onSchedule({
  schedule: "every day 00:00",
}, async (event) => {
  const db = admin.firestore();
  const now = new Date();
  
  // Expiry threshold: 7 days ago
  const threshold = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  
  logger.info(`[cleanupExpiredDonations] Starting scheduled cleanup for donations expired before ${threshold.toISOString()}`);
  
  try {
    const expiredQuery = db.collection("food_donations")
      .where("expiresAt", "<", admin.firestore.Timestamp.fromDate(threshold));
      
    const snapshot = await expiredQuery.get();
    
    if (snapshot.empty) {
      logger.info("[cleanupExpiredDonations] No expired food donations older than 7 days found.");
      return;
    }
    
    logger.info(`[cleanupExpiredDonations] Found ${snapshot.size} expired food donations to delete.`);
    
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    logger.info("[cleanupExpiredDonations] Successfully deleted expired food donations. Triggering cascaded image cleanups.");
  } catch (error: any) {
    logger.error(`[cleanupExpiredDonations] Failed to perform scheduled cleanup: ${error.message || error}`, { error });
    throw error;
  }
});
