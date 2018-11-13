//
//  NXMEventsDispatcherNotificationHelper.h
//  StitchObjC
//
//  Created by Doron Biaz on 9/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMEventsDispatcherConstants.h"
#import "NXMEvent.h"
#import "NXMEventsDispatcherConnectionStatusModel.h"
#import "NXMEventsDispatcherLoginStatusModel.h"

@interface NXMEventsDispatcherNotificationHelper<NotificationModel> : NSObject
+(NotificationModel)nxmNotificationModelWithNotification:(NSNotification *)notification;
+(NSDictionary *)notificationUserInfoWithNotificationModel:(NotificationModel)notificationModel;
@end
