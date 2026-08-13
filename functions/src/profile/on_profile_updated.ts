import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { CloudinaryService } from "../cloudinary/cloudinary_service";
import { logger } from "firebase-functions";

export const onProfileUpdated = onDocumentUpdated({
  document: "users/{uid}",
  secrets: ["CLOUDINARY_CLOUD_NAME", "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET"],
}, async (event) => {
  const change = event.data;
  if (!change) return;

  const beforeData = change.before.data();
  const afterData = change.after.data();

  const oldPublicId = beforeData?.imagePublicId;
  const newPublicId = afterData?.imagePublicId;

  if (oldPublicId && oldPublicId !== newPublicId) {
    logger.info(`[onProfileUpdated] Detected image replacement for user ${event.params.uid}. Deleting old image ${oldPublicId}.`);
    await CloudinaryService.deleteImage(oldPublicId, "users", event.params.uid);
  }
});
