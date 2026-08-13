import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { CloudinaryService } from "../cloudinary/cloudinary_service";
import { logger } from "firebase-functions";

export const onFoodUpdated = onDocumentUpdated({
  document: "food_donations/{donationId}",
  secrets: ["CLOUDINARY_CLOUD_NAME", "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET"],
}, async (event) => {
  const change = event.data;
  if (!change) return;

  const beforeData = change.before.data();
  const afterData = change.after.data();

  const oldPublicId = beforeData?.imagePublicId;
  const newPublicId = afterData?.imagePublicId;

  if (oldPublicId && oldPublicId !== newPublicId) {
    logger.info(`[onFoodUpdated] Detected image replacement for food donation ${event.params.donationId}. Deleting old image ${oldPublicId}.`);
    await CloudinaryService.deleteImage(oldPublicId, "food_donations", event.params.donationId);
  }
});
