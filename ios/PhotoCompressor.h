#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNPhotoCompressorSpec.h"

@interface PhotoCompressor : RCTEventEmitter <NativePhotoCompressorSpec>
#else
#import <React/RCTBridgeModule.h>

@interface PhotoCompressor : RCTEventEmitter <RCTBridgeModule>
#endif

@end
