//
//  NXMEventsDispatcherNotificationHelper.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMEventsDispatcherConstants.h"
#import "NXMEventsDispatcherConnectionStatusModel.h"
#import "NXMEventsDispatcherLoginStatusModel.h"

@interface NXMEventsDispatcherNotificationHelper<NotificationModel> : NSObject
+(NotificationModel)nxmNotificationModelWithNotification:(NSNotification *)notification;
+(NSDictionary *)notificationUserInfoWithNotificationModel:(NotificationModel)notificationModel;
@end
