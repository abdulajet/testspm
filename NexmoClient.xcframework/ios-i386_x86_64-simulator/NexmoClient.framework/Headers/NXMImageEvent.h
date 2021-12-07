//
//  NXMImageEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMessageEvent.h"
#import "NXMImageInfo.h"

/**
 * Represents an image event that can be sent and received on an `NXMConversation`.
 */
@interface NXMImageEvent : NXMMessageEvent

/// A unique identifier for the event.
@property (nonatomic, readonly, nonnull) NSString *imageUuid;

/// Image info at a medium size.
@property (nonatomic, readonly, nonnull) NXMImageInfo *mediumImage;

/// Image info at its original size.
@property (nonatomic, readonly, nonnull) NXMImageInfo *originalImage;

/// Image info at a thumbnail size.
@property (nonatomic, readonly, nonnull) NXMImageInfo *thumbnailImage;
@end
