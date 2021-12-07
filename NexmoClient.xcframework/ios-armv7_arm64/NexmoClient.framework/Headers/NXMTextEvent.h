//
//  NXMTextEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"

/**
 * Represents a text event that is sent and received on an `NXMConversation`.
 */
@interface NXMTextEvent : NXMEvent

/// The text of the event.
@property (nonatomic, nullable, readonly) NSString *text;

/// The state of the event.
@property (nonatomic, readonly, nonnull) NSDictionary<NSNumber *, NSDictionary<NSString *, NSDate *> *> *state;

@end
