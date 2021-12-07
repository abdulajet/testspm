//
//  NXMMemberEvent.h
//  NexmoNClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"

@class NXMMediaSettings;
@class NXMChannel;

/**
 * Represents a member event that is received on an `NXMConversation`.
 */
@interface NXMMemberEvent : NXMEvent

/// The member ID of the event.
@property (nonatomic, readonly, nonnull) NSString *memberId;

/// The state of the member.
@property (nonatomic) NXMMemberState state;

/// The media settings of the member.
@property (nonatomic, readonly, nullable) NXMMediaSettings *media;

/// The member's `NXMChannel` data.
@property (nonatomic, readonly, nullable) NXMChannel *channel;

/// The knocking ID.
@property (nonatomic, copy, nullable) NSString *knockingId;

/// The member ID who invited the event's member.
@property (nonatomic, readonly, nullable) NSString *invitedBy;

@end
