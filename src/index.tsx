const PhotoCompressor = require('./NativePhotoCompressor').default;

export function compressPhoto(uri: string, quality: number): Promise<string> {
  return PhotoCompressor.compressPhoto(uri, quality);
}

export function getSizeInBytes(uri: string): Promise<number> {
  return PhotoCompressor.getSizeInBytes(uri);
}
