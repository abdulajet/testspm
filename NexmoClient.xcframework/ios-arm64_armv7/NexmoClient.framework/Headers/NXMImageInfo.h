//
//  NXMImageInfo.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A list of the image sizes.
 */
typedef NS_ENUM(NSInteger, NXMImageSize) {
    /// Medium image size
    NXMImageSizeMedium,
    /// Original image size
    NXMImageSizeOriginal,
    /// Thumbnail image size
    NXMImageSizeThumbnail
};

/**
 * Information about an image, used in `NXMImageEvent`
 */
@interface NXMImageInfo : NSObject

/// A unique identifier of the image.
@property (nonatomic, readonly, nonnull) NSString *imageUuid;

/// URL of the image.
@property (nonatomic, readonly, nonnull) NSURL *url;

/// The size of the image in bytes.
@property (readonly) NSInteger sizeInBytes;

/// The size of the image as an `NXMImageSize`.
@property (readonly) NXMImageSize size;

@end
