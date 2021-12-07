//
//  NXMMessageEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"

/**
 * A base class for both `NXMImageEvent` and `NXMTextEvent`.
 */
@interface NXMMessageEvent : NXMEvent

/// The state of the event.
@property (nonatomic, readonly, nonnull) NSDictionary<NSNumber *, NSDictionary<NSString *, NSDate *> *> *state;
@end
