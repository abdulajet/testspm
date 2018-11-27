//
//  AppDelegate.h
//  StitchTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>


@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly, strong) NSData *deviceToken;


@end

