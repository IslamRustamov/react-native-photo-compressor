#import "RNPhotoCompressorSpec.h"
#import "PhotoCompressor.h"

@implementation PhotoCompressor
RCT_EXPORT_MODULE()

- (void)compressPhoto:(NSString *)uri quality:(double)quality fileName:(NSString *)fileName forceRewrite:(NSNumber *)forceRewrite resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;

        NSString *formattedUri = [uri stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        BOOL isForceRewrite = [forceRewrite boolValue];
        
        NSString *dirPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"RNPhotoCompressorImages"];
        if (![fileManager fileExistsAtPath:dirPath]) {
            [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        
        NSString *fileFullName;
        if ([fileName isKindOfClass:[NSString class]]) {
            fileFullName = [fileName stringByAppendingString:@".jpg"];
        } else {
            NSString *uuid = [[NSUUID UUID] UUIDString];
            fileFullName = [uuid stringByAppendingString:@".jpg"];
        }

        NSString *filePath = [dirPath stringByAppendingPathComponent:fileFullName];
        
        if ([fileManager fileExistsAtPath:filePath] && !isForceRewrite) {
            return reject(@"file_exist", @"File with this name already exists", error);
        }

        UIImage *image;
        
        if ([uri hasPrefix:@"http"]) {
            NSURL *url = [NSURL URLWithString:uri];
            NSData *data = [NSData dataWithContentsOfURL:url];
            image = [[UIImage alloc] initWithData:data];
        } else {
            image = [UIImage imageWithContentsOfFile: formattedUri];
        }
        
        NSData *compressedImage = UIImageJPEGRepresentation(image, quality/100);
        
        [compressedImage writeToFile:filePath atomically:YES];

        NSString *result = [@"file://" stringByAppendingString:filePath];
        resolve(result);
    } catch (NSError *error) {
        reject(@"compressPhoto_failed", @"Photo compression failed.", error);
    }
}

- (void)getSizeInBytes:(NSString *)uri size:(NSString *)size resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *formattedUri = [uri stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSError *error = nil;

        BOOL exists = [fileManager fileExistsAtPath:formattedUri];
        if (!exists) {
            return reject(@"ENOENT", @"ENOENT: no such file or directory", error);
        }

        NSDictionary *attrs = [fileManager attributesOfItemAtPath: formattedUri error: &error];
        UInt32 fileSize = [attrs fileSize];
        NSNumber *result = @(fileSize);
        
        if ([size isEqualToString:@"kb"]) {
            return resolve(@([result doubleValue] / 1024));
        } else if ([size isEqualToString:@"mb"]) {
            return resolve(@([result doubleValue] / 1024 / 1024));
        }
        
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
