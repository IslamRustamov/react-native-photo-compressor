import { NativeEventEmitter, type NativeEventSubscription } from 'react-native';

const PhotoCompressor = require('./NativePhotoCompressor').default;

const CompressPhotosEventEmitter = new NativeEventEmitter(PhotoCompressor);

export function compressPhoto(
  uri: string,
  quality: number,
  fileName?: string,
  forceRewrite = false
): Promise<string> {
  return PhotoCompressor.compressPhoto(uri, quality, fileName, forceRewrite);
}

export async function compressPhotos(
  photos: string[],
  quality: number,
  rejectAll = true,
  onProgress?: (progress: number) => void
): Promise<string[]> {
  let subscription: NativeEventSubscription;
  let result: string[];

  try {
    if (onProgress) {
      subscription = CompressPhotosEventEmitter.addListener(
        'compressProgress',
        (event: number) => {
          onProgress(event);
        }
      );
    }

    result = await PhotoCompressor.compressPhotos(photos, quality, rejectAll);
  } catch (e) {
    console.log(e);
  } finally {
    // @ts-ignore
    if (subscription) {
      subscription.remove();
    }
  }
  // @ts-ignore
  return result;
}

export function getSizeInBytes(uri: string, size = 'b'): Promise<number> {
  return PhotoCompressor.getSizeInBytes(uri, size);
}

export function deletePhoto(uri: string): Promise<void> {
  return PhotoCompressor.deletePhoto(uri);
}
