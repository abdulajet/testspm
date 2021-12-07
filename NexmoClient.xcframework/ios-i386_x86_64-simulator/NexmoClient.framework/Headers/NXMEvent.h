//
//  NXMEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMEnums.h"
#import "NXMMember.h"

/**
 This is a base class for the events that you and send and receive on an `NXMConversation`.
 */
@interface NXMEvent : NSObject

/// A unique identifier for the Conversation the event is on.
@property (nonatomic, copy, nonnull) NSString *conversationUuid;

/// The member who sent the event or the event originated from.
@property (nonatomic, readonly, nullable) NXMMember *fromMember;

/// The event's creation date.
@property (nonatomic, copy, nonnull) NSDate *creationDate;

/// The event's possible deletion date.
@property (nonatomic, copy, nullable) NSDate *deletionDate;

/// The event's type.
@property (nonatomic, readonly) NXMEventType type;

/// A unique identifier for the event.
@property (nonatomic, readonly) NSInteger uuid;

@end
