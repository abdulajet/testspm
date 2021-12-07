//
//  NXMTextEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMessageEvent.h"

/**
 * Represents a text event that is sent and received on an `NXMConversation`.
 */
@interface NXMTextEvent : NXMMessageEvent

/// The text of the event.
@property (nonatomic, nullable, readonly) NSString *text;
@end
