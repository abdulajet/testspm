//
//  NXMTextTypingEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"
#import "NXMEnums.h"

/**
 * Represents a typing event that is sent and received on an `NXMConversation`.
 */
@interface NXMTextTypingEvent : NXMEvent

/// The status of the text event.
@property (nonatomic, readonly) NXMTextTypingEventStatus status;

@end
