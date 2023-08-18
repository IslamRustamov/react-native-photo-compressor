
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNPhotoCompressorSpec.h"

@interface PhotoCompressor : NSObject <NativePhotoCompressorSpec>
#else
#import <React/RCTBridgeModule.h>

@interface PhotoCompressor : NSObject <RCTBridgeModule>
#endif

@end
