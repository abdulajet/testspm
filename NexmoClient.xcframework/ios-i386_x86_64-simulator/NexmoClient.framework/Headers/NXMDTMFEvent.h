//
//  NXMDTMFEvent.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMEvent.h"

/**
 * Represents a DTMF event that can be sent and received on an `NXMConversation`.
 */
@interface NXMDTMFEvent : NXMEvent

/// The digit sent.
@property (nullable, nonatomic, readonly, copy) NSString *digit;

/// The tone duration.
@property (nullable, nonatomic, readonly, copy) NSNumber *duration;

@end

