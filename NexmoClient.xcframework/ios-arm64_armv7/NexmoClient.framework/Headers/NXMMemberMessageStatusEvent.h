//
//  NXMMemberMessageStatusEvent.h
//  NXMiOSSDK
//
//  Created by Dimitris Niras on 04/11/21.
//  Copyright © 2021 Vonage. All rights reserved.
//

#import "NXMEvent.h"
#import "NXMEnums.h"
#import "NXMLeg.h"

/**
 * Represents a member message status event that can be received on an `NXMConversation`.
 */
@interface NXMMemberMessageStatusEvent : NXMEvent

/// The event id of the original message.
@property (nonatomic, readonly) NSInteger originalEventId;

/// The channel type of the sender.
@property (nonatomic, readonly, nonnull) NSString *channelType;

/// The id/number of the sender.
@property (nonatomic, readonly, nonnull) NSString *from;

/// The id/number of the recepient.
@property (nonatomic, readonly, nonnull) NSString *to;

/// The message uuid of the sent message.
@property (nonatomic, readonly, nullable) NSString *messageUuid;

/// The error in case the message was not delivered properly.
@property (nonatomic, readonly, nullable) NSDictionary *error;

/// The content of the message.
@property (nonatomic, readonly, nonnull) NSDictionary *content;

@end

