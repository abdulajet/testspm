//
//  NXMEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEnums.h"
#import "NXMEventEmbeddedInfo.h"
#import "NXMMember.h"

/**
 This is a base class for the events that you and send and receive on an `NXMConversation`.
 */
@interface NXMEvent : NSObject

/// A unique identifier for the Conversation the event is on.
@property (nonatomic, copy, nonnull) NSString *conversationUuid;

/// The member identifier for the event sender.
@property (nonatomic, readonly, nonnull) NSString *fromMemberId;

/// The event's creation date.
@property (nonatomic, copy, nonnull) NSDate *creationDate;

/// The event's possible deletion date.
@property (nonatomic, copy, nullable) NSDate *deletionDate;

/// The event's type.
@property (nonatomic, readonly) NXMEventType type;

/// A unique identifier for the event.
@property (nonatomic, readonly) NSInteger uuid;

/// The event's extra information about event producer like NXUser.
@property (nonatomic, readonly, nullable) NXMEventEmbeddedInfo *embeddedInfo;

@end
