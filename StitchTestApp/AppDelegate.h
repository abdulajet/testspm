//
//  AppDelegate.h
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#import "StitchObjC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NXMConversationCoreDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly, strong) NXMConversationCore *stitchConversation;
@property (nonatomic, readonly, strong) NSData *deviceToken;

- (void)setStitch:(NXMConversationCore *)stitch;
- (void)addConversationMember:(NSString *)conv  memberId:(NSString *)memberId;

@end

