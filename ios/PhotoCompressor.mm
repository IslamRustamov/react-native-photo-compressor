#import "RNPhotoCompressorSpec.h"
#import "PhotoCompressor.h"

@implementation PhotoCompressor
RCT_EXPORT_MODULE()

- (void)compressPhoto:(NSString *)uri quality:(double)quality resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;

    NSString *formattedUri = [uri stringByReplacingOccurrencesOfString:@"file://" withString:@""];

    UIImage *image = [UIImage imageWithContentsOfFile: formattedUri];
    NSData *compressedImage = UIImageJPEGRepresentation(image, quality/100);

    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *fileName = [uuid stringByAppendingString:@".jpg"];
    NSString *dirPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"RNPhotoCompressorImages"];

    if (![fileManager fileExistsAtPath:dirPath]) {
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:&error];
    }

    NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];

    [compressedImage writeToFile:filePath atomically:YES];

    NSString *result = [@"file://" stringByAppendingString:filePath];
    resolve(result);
}

- (void)getSizeInBytes:(NSString *)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *formattedUri = [uri stringByReplacingOccurrencesOfString:@"file://" withString:@""];

    NSDictionary *attrs = [fileManager attributesOfItemAtPath: formattedUri error: NULL];
    UInt32 size = [attrs fileSize];
    NSNumber *result = @(size);

    resolve(result);
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativePhotoCompressorSpecJSI>(params);
}
#endif

@end
