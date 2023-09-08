const PhotoCompressor = require('./NativePhotoCompressor').default;

export function compressPhoto(
  uri: string,
  quality: number,
  fileName?: string,
  forceRewrite = false
): Promise<string> {
  return PhotoCompressor.compressPhoto(uri, quality, fileName, forceRewrite);
}

export function getSizeInBytes(uri: string): Promise<number> {
  return PhotoCompressor.getSizeInBytes(uri);
}

export function deletePhoto(uri: string): Promise<void> {
  return PhotoCompressor.deletePhoto(uri);
}
