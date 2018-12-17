//
//  NXMEventsDispatcherNotificationHelper.m
//  StitchObjC
//
//  Created by Doron Biaz on 9/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEventsDispatcherNotificationHelper.h"

@implementation NXMEventsDispatcherNotificationHelper
+(id)nxmNotificationModelWithNotification:(NSNotification *)notification {
    return notification.userInfo[kNXMDispatchUserInfoEventKey];
}

+(NSDictionary *)notificationUserInfoWithNotificationModel:(id)notificationModel {
    return @{kNXMDispatchUserInfoEventKey:notificationModel};
}
@end
