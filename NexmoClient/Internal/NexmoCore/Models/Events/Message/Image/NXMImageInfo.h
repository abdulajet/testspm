//
//  NXMImageInfo.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXMImageSize) {
    NXMImageSizeMedium,
    NXMImageSizeOriginal,
    NXMImageSizeThumbnail
};

@interface NXMImageInfo : NSObject
@property (nonatomic, strong, nonnull) NSString *imageId;
@property (nonatomic, strong, nonnull) NSURL *url;
@property NSInteger sizeInBytes;
@property NXMImageSize size;

- (nullable instancetype)initWithId:(nonnull NSString *)imageId size:(NSInteger)size url:(nonnull NSURL *)url type:(NXMImageSize)type;

@end
