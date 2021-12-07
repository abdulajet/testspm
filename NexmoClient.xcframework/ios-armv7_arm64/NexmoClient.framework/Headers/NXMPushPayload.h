//
//  NXMPushEvent.h
//  NexmoClient
//
//  Copyright © 2020 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMEnums.h"

/**
 * A class representing the payload from an incoming push notification.
 */
@interface NXMPushPayload : NSObject

/// Custom data on the push notification payload.
@property (nonatomic, readonly, nullable) NSDictionary *customData;

/// Event data on the push notification payload.
@property (nonatomic, readonly, nullable) NSDictionary *eventData;

/// The template of the push notification payload.
@property (nonatomic, readonly) NXMPushTemplate template;

@end


