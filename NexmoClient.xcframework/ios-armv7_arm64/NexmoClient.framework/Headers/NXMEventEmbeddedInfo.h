//
//  NXMEventEmbeddedInfo.h
//  NexmoClient
//
//  Copyright © 2021 Vonage. All rights reserved.
//

@import Foundation;

@class NXMUser;

/**
 * The extra embedded info associated to an event.
 */
@interface NXMEventEmbeddedInfo : NSObject

/// The user associated to the event.
@property (nonnull, readonly, nonatomic) NXMUser *user;

@end
