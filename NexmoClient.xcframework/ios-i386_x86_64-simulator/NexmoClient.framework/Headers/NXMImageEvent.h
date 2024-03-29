//
//  NXMImageEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"
#import "NXMImageInfo.h"

/**
 * Represents an image event that can be sent and received on an `NXMConversation`.
 */
@interface NXMImageEvent : NXMEvent

/// A unique identifier for the event.
@property (nonatomic, readonly, nonnull) NSString *imageUuid;

/// Image info at a medium size.
@property (nonatomic, readonly, nonnull) NXMImageInfo *mediumImage;

/// Image info at its original size.
@property (nonatomic, readonly, nonnull) NXMImageInfo *originalImage;

/// Image info at a thumbnail size.
@property (nonatomic, readonly, nonnull) NXMImageInfo *thumbnailImage;

/// The state of the event.
@property (nonatomic, readonly, nonnull) NSDictionary<NSNumber *, NSDictionary<NSString *, NSDate *> *> *state;

@end
