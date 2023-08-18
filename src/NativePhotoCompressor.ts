import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  compressPhoto(uri: string, quality: number): Promise<string>;
  getSizeInBytes(uri: string): Promise<number>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('PhotoCompressor');
