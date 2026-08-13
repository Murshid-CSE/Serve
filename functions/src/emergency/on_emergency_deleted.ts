import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { CloudinaryService } from "../cloudinary/cloudinary_service";

export const onEmergencyDeleted = onDocumentDeleted({
  document: "emergency_requests/{alertId}",
  secrets: ["CLOUDINARY_CLOUD_NAME", "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET"],
}, async (event) => {
  const snap = event.data;
  if (!snap) return;

  const data = snap.data();
  const publicId = data?.imagePublicId;

  if (publicId) {
    await CloudinaryService.deleteImage(publicId, "emergency_requests", event.params.alertId);
  }
});
