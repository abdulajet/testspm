//
//  NXMMember.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

@import Foundation;

#import "NXMEnums.h"
#import "NXMUser.h"
#import "NXMMediaSettings.h"
#import "NXMChannel.h"

/**
 * The NXMMember class represents a Member of a Conversation (`NXMConversation`). In order for a User to communicate through a Conversation they must join the Conversation through a membership.
 */
@interface NXMMember : NSObject

/// The Conversation ID
@property (nonatomic, copy, nonnull) NSString *conversationUuid;

/// The Member ID
@property (nonatomic, copy, nonnull) NSString *memberUuid;

/// The User object for this Member.
@property (nonatomic, readonly, nonnull) NXMUser *user;

/// The state of the Member.
@property (nonatomic, readonly) NXMMemberState state;

/// The media settings of the Member.
@property (nonatomic, readonly, nullable) NXMMediaSettings *media;

/// The channel details of the Member.
@property (nonatomic, readonly, nullable) NXMChannel *channel;

/// Mutes the NXMMember's stream.
- (void)enableMute;

/// Unmutes the NXMMember's stream.
- (void)disableMute;

@end
