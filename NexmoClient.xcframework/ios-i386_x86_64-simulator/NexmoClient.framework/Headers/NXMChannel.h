//
//  NXMChannel.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMEnums.h"
#import "NXMLeg.h"

/**
 Directional data from Conversation Service (Conversation API).
 */
@interface NXMDirection : NSObject

/// The type of direction.
@property (nonatomic, assign) NXMDirectionType type;

/// The data of the direction.
@property (nonatomic, copy, nullable) NSString *data;
@end

/**
 The NXMChannel is how the user connects to the `NXMConversation`.
 */
@interface NXMChannel : NSObject

/// The from direction data of the channel.
@property (nonatomic, readonly, nonnull) NXMDirection *from;

/// The to direction data of the channel.
@property (nonatomic, readonly, nullable) NXMDirection *to;

/// The `NXMLeg` of the channel.
@property (nonatomic, readonly, nullable) NXMLeg *leg;

@end

