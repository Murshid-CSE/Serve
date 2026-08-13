import * as cloudinary from "cloudinary";
import { logger } from "firebase-functions";

export class CloudinaryService {
  private static isConfigured = false;

  private static configure() {
    if (this.isConfigured) return;

    const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
    const apiKey = process.env.CLOUDINARY_API_KEY;
    const apiSecret = process.env.CLOUDINARY_API_SECRET;

    if (!cloudName || !apiKey || !apiSecret) {
      logger.error("Cloudinary credentials missing from environment.");
      throw new Error("Cloudinary configuration failed: Missing credentials.");
    }

    cloudinary.v2.config({
      cloud_name: cloudName,
      api_key: apiKey,
      api_secret: apiSecret,
      secure: true,
    });
    this.isConfigured = true;
  }

  /**
   * Delete an image from Cloudinary by its public ID.
   * Handles logging, exponential backoff retries, and idempotency.
   */
  public static async deleteImage(
    publicId: string,
    collectionName: string,
    docId: string
  ): Promise<boolean> {
    if (!publicId) {
      logger.info(`[CloudinaryService] No publicId provided for doc ${docId} in ${collectionName}. Skipping.`, {
        collection: collectionName,
        docId,
      });
      return false;
    }

    let retryCount = 0;
    const maxRetries = 2;
    const baseDelay = 1000;

    while (true) {
      try {
        this.configure();

        logger.info(`[CloudinaryService] Attempting to delete image ${publicId} for doc ${docId} in ${collectionName}...`, {
          publicId,
          collection: collectionName,
          docId,
          attempt: retryCount + 1,
        });

        const result = await cloudinary.v2.uploader.destroy(publicId, {
          invalidate: true,
        });

        if (result.result === "ok") {
          logger.info(`[CloudinaryService] Successfully deleted image ${publicId} for doc ${docId} in ${collectionName}.`, {
            publicId,
            collection: collectionName,
            docId,
            result,
          });
          return true;
        } else if (result.result === "not found") {
          logger.warn(`[CloudinaryService] Image ${publicId} not found in Cloudinary for doc ${docId} in ${collectionName}. Treating as success.`, {
            publicId,
            collection: collectionName,
            docId,
            result,
          });
          return true;
        } else {
          throw new Error(`Cloudinary destroy returned unexpected result: ${result.result}`);
        }
      } catch (error: any) {
        logger.error(`[CloudinaryService] Failed to delete image ${publicId} on attempt ${retryCount + 1}: ${error.message || error}`, {
          publicId,
          collection: collectionName,
          docId,
          error,
        });

        if (retryCount < maxRetries) {
          retryCount++;
          const delay = baseDelay * Math.pow(2, retryCount);
          await new Promise((resolve) => setTimeout(resolve, delay));
          continue;
        }

        logger.error(`[CloudinaryService] Exhausted all retries. Failed to delete image ${publicId} for doc ${docId} in ${collectionName}.`, {
          publicId,
          collection: collectionName,
          docId,
        });
        return false;
      }
    }
  }
}
