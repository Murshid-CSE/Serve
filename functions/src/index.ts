import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK globally
admin.initializeApp();

// Export triggers
export { onFoodDeleted } from "./food/on_food_deleted";
export { onFoodUpdated } from "./food/on_food_updated";
export { onProfileUpdated } from "./profile/on_profile_updated";
export { onProfileDeleted } from "./profile/on_profile_deleted";
export { onEmergencyDeleted } from "./emergency/on_emergency_deleted";

// Export schedulers
export { cleanupExpiredDonations } from "./scheduler/cleanup_expired";
