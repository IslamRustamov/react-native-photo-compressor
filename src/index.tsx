import { NativeEventEmitter, NativeEventSubscription } from 'react-native';

const PhotoCompressor = require('./NativePhotoCompressor').default;

const CompressPhotoArrayEventEmitter = new NativeEventEmitter(PhotoCompressor);

export function compressPhoto(
  uri: string,
  quality: number,
  fileName?: string,
  forceRewrite = false
): Promise<string> {
  return PhotoCompressor.compressPhoto(uri, quality, fileName, forceRewrite);
}

export async function compressPhotoArray(
  photos: string[],
  quality: number,
  rejectAll = true,
  onProgress?: (progress: number) => void
): Promise<string[]> {
  let subscription: NativeEventSubscription;

  try {
    if (onProgress) {
      subscription = CompressPhotoArrayEventEmitter.addListener(
        'compressProgress',
        (event: number) => {
          onProgress(event);
        }
      );
    }

    return await PhotoCompressor.compressPhotoArray(photos, quality, rejectAll);
  } catch (e) {
    console.log(e);
  } finally {
    if (subscription) {
      subscription.remove();
    }
  }
}

export function getSizeInBytes(uri: string, size = 'b'): Promise<number> {
  return PhotoCompressor.getSizeInBytes(uri, size);
}

export function deletePhoto(uri: string): Promise<void> {
  return PhotoCompressor.deletePhoto(uri);
}
