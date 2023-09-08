#import "RNPhotoCompressorSpec.h"
#import "PhotoCompressor.h"

@implementation PhotoCompressor
RCT_EXPORT_MODULE()

- (void)compressPhoto:(NSString *)uri quality:(double)quality resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;

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
    } catch (NSError *error) {
        reject(@"compressPhoto_failed", @"Photo compression failed.", error);
    }
}

- (void)getSizeInBytes:(NSString *)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *formattedUri = [uri stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSError *error = nil;

        BOOL exists = [fileManager fileExistsAtPath:formattedUri];
        if (!exists) {
            return reject(@"ENOENT", @"ENOENT: no such file or directory", error);
        }

        NSDictionary *attrs = [fileManager attributesOfItemAtPath: formattedUri error: &error];
        UInt32 size = [attrs fileSize];
        NSNumber *result = @(size);

        resolve(result);
    } catch (NSError *error) {
        reject(@"getSize_failed", @"Getting size failed.", error);
    }
}

- (void)deletePhoto:(NSString *)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *formattedUri = [uri stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSError *error = nil;

        BOOL exists = [fileManager fileExistsAtPath:formattedUri];
        if (!exists) {
            return reject(@"ENOENT", @"ENOENT: no such file or directory", error);
        }

        BOOL isValidDir = [formattedUri containsString:@"/RNPhotoCompressorImages/"];
        if (!isValidDir) {
            return reject(@"incorrect_dir", @"Incorrect directory.", error);
        }

        [fileManager removeItemAtPath: formattedUri error: &error];

        resolve(nil);
    } catch (NSError *error) {
        reject(@"deletePhoto_failed", @"File deletion failed.", error);
    }
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativePhotoCompressorSpecJSI>(params);
}
#endif

@end
