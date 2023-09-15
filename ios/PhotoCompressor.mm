#import "RNPhotoCompressorSpec.h"
#import "PhotoCompressor.h"

@implementation PhotoCompressor
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents {
  return @[@"compressProgress"];
}

- (NSString *)compressImage:(NSString *)uri quality:(double)quality fileName:(NSString *)fileName forceRewrite:(NSNumber *)forceRewrite resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *result;
    
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
            @throw [NSError errorWithDomain: @"File with this name already exists." code:0 userInfo:nil];
        }

        UIImage *image;

        if ([uri hasPrefix:@"http"]) {
            NSURL *url = [NSURL URLWithString:uri];
            NSData *data = [NSData dataWithContentsOfURL:url];
            image = [[UIImage alloc] initWithData:data];
        } else {
            image = [UIImage imageWithContentsOfFile: formattedUri];
        }

        if (image == nil) {
            @throw [NSError errorWithDomain: @"Invalid path received." code:0 userInfo:nil];
        }

        NSData *compressedImage = UIImageJPEGRepresentation(image, quality/100);

        [compressedImage writeToFile:filePath atomically:YES];

        result = [@"file://" stringByAppendingString:filePath];
        
        if (resolve) {
            resolve(result);
        }
    } catch (NSError *error) {
        if (reject) {
            reject(@"compressPhoto_error", @"Photo compression failed.", error);
        }
    }

    return result;
}

- (void)compressPhoto:(NSString *)uri quality:(double)quality fileName:(NSString *)fileName forceRewrite:(NSNumber *)forceRewrite resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self compressImage:uri quality:quality fileName:fileName forceRewrite:forceRewrite resolve:resolve reject:reject];
    });
}

- (void)compressPhotos:(NSArray *)photos quality:(double)quality rejectAll:(NSNumber *)rejectAll resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *result = [[NSMutableArray alloc] init];
        BOOL isRejectAll = [rejectAll boolValue];
        
        try {
            for (int i = 0; i < [photos count]; i++){
                NSString *compressedImage = [self compressImage:photos[i] quality:quality fileName: nil forceRewrite: nil resolve:nil reject:nil];
                
                if (!compressedImage && isRejectAll) {
                    @throw [NSError errorWithDomain: [NSString stringWithFormat:@"Compression of image at index %d was failed.", i] code:0 userInfo:nil];
                }
                
                [result addObject:[compressedImage isKindOfClass:[NSString class]] ? compressedImage : [NSNull null]];
                [self sendEventWithName:@"compressProgress" body:@(i)];
            }
            
            resolve(result);
        } catch (NSError *error) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            for (int i = 0; i < [result count]; i++){
                NSString *formattedUri = [result[i] stringByReplacingOccurrencesOfString: @"file://" withString:@""];
                NSError *error = nil;
                
                [fileManager removeItemAtPath: formattedUri error: &error];
            }
            
            reject(@"compressPhotoArray_error", @"Photo compression failed.", error);
        }
    });
}

- (void)getSizeInBytes:(NSString *)uri size:(NSString *)size resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
            reject(@"getSize_error", @"Getting size failed.", error);
        }
    });
}

- (void)deletePhoto:(NSString *)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
            reject(@"deletePhoto_error", @"File deletion failed.", error);
        }
    });
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativePhotoCompressorSpecJSI>(params);
}
#endif

@end
