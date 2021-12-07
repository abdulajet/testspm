//
//  NXMMediaEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"
#import "NXMMediaSettings.h"

/**
 * Represents a media event that is sent and received on an `NXMConversation`.
 */
@interface NXMMediaEvent : NXMEvent

/// Whether media is enabled or not.
@property (nonatomic, readonly) BOOL isEnabled;

/// Whether media is suspended or not.
@property (nonatomic, readonly) BOOL isSuspended;

@end
