//
//  NXMMessageStatusEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"

/**
 * Represents a message status event that is sent and received on an NXMConversation.
 */
@interface NXMMessageStatusEvent : NXMEvent

/// A reference to the unique ID of the message the status event belongs to
@property (nonatomic, readonly) NSInteger referenceEventUuid;

/// The message status.
@property (nonatomic, readonly) NXMMessageStatusType status;

@end
