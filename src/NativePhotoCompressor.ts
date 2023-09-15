import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  compressPhoto(
    uri: string,
    quality: number,
    fileName?: string,
    forceRewrite?: boolean
  ): Promise<string>;
  compressPhotos(
    photos: string[],
    quality: number,
    rejectAll?: boolean
  ): Promise<string[]>;
  getSizeInBytes(uri: string, size?: string): Promise<number>;
  deletePhoto(uri: string): Promise<void>;
  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('PhotoCompressor');
