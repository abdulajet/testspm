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
 Provides a textual description for a given NXMEventType.
 @param eventType The event type you want the description for.
 @code NSString *eventTypeDescription = [NXMHelper descriptionForEventType:eventType];
*/
+ (nonnull NSString *)descriptionForEventType:(NXMEventType)eventType;

/**
 Provides a textual description for a given NXMCallMemberStatus.
 @param callMemberStatus The call member status you want the description for.
 @code NSString *callMemberStatusDescription = [NXMHelper descriptionForCallMemberStatus:callMemberStatus];
*/
+ (nonnull NSString *)descriptionForCallMemberStatus:(NXMCallMemberStatus)callMemberStatus;

@end
