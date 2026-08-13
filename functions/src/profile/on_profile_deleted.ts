import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { CloudinaryService } from "../cloudinary/cloudinary_service";

export const onProfileDeleted = onDocumentDeleted({
  document: "users/{uid}",
  secrets: ["CLOUDINARY_CLOUD_NAME", "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET"],
}, async (event) => {
  const snap = event.data;
  if (!snap) return;

  const data = snap.data();
  const publicId = data?.imagePublicId;

  if (publicId) {
    await CloudinaryService.deleteImage(publicId, "users", event.params.uid);
  }
});
