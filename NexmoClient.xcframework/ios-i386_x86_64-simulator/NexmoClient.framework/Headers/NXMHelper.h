//
//  NXMHelper.h
//  NexmoClient
//
//  Copyright © 2020 Vonage. All rights reserved.
//

#import "NXMEnums.h"

/**
 *  Helper methods.
 */
@interface NXMHelper : NSObject

/**
 Provides a textual description for a given NXMEventType
 @param eventType The event type you want the description for.
 @code NSString *eventTypeDescription = [NXMHelper descriptionForEventType:eventType];
*/
+ (nonnull NSString *)descriptionForEventType:(NXMEventType)eventType;

@end
