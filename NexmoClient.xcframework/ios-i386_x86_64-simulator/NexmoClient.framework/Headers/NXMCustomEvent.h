//
//  NXMCustomEvent.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMEvent.h"
#import "NXMCustomEvent.h"

/**
 * Represents a custom event that can be sent and received on an `NXMConversation`.
 */
@interface NXMCustomEvent : NXMEvent

/// The type of custom event that you supply. This allows you to differentiate between your custom events.
@property (nonatomic, copy, nullable) NSString *customType;

/// The data of the custom event.
@property (nonatomic, readonly, nullable) NSDictionary *data;

@end
