//
//  MainFlow.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/20/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "MainFlow.h"
#import "CallViewController.h"
#import "CommunicationsManagerDefine.h"
#import "NTAUserInfoProvider.h"
#import "InAppCallCreator.h"
#import "IncomingCallCreator.h"
#import "CallsDefine.h"
#import "NTALogger.h"

#import <UserNotifications/UserNotifications.h>

@interface CallsWindow : UIWindow

@property (strong, nonatomic) CallViewController *callVC;

@end

@implementation CallsWindow

@end

@interface MainFlow()

@property (strong, nonatomic) CallsWindow *callWindow;
@property (strong, nonatomic) UIWindow *appWindow;

@end

@implementation MainFlow

static MainFlow *sharedInstance;

/// singleton method
+ (MainFlow *)sharedInstance {
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[MainFlow alloc] init];
            sharedInstance.callWindow = [[CallsWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        }
    }
    return sharedInstance;
}

- (void)startMainFlowWithAppWindow:(UIWindow *)appWindow {
    self.appWindow = appWindow;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(incomingCallWithNotification:) name:kNTACommunicationsManagerNotificationNameIncomingCall object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callEnded:) name:kNTACallsDefineNotificationNameEndCall object:nil];
    [self.appWindow makeKeyAndVisible];
}

- (void)incomingCallWithNotification:(NSNotification *)note {
    [NTALogger info:@"MainFlow - incoming call"];
    NXMCall *call = note.userInfo[kNTACommunicationsManagerNotificationKeyIncomingCall];
    [self incomingCall:call];
}

- (void)incomingCall:(NXMCall *)call {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callWindow.callVC != nil) {
            return;
        }
        [NTALogger info:@"MainFlow - creating incoming call view controller"];

        
        IncomingCallCreator *creator = [[IncomingCallCreator alloc] initWithCall:call];
        self.callWindow.callVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Call"];
        
        if (call.otherCallMembers[0].channel.from.type == NXMDirectionTypeApp) {
            NTAUserInfo *userInfo  = [NTAUserInfoProvider getUserInfoForCSUserName:call.otherCallMembers[0].user.name];
            [self.callWindow.callVC updateWithContactUserInfo:userInfo callCreator:creator andIsIncomingCall:YES];
        } else {
            [self.callWindow.callVC updateWithNumber:call.otherCallMembers[0].channel.from.data callCreator:creator andIsIncomingCall:YES];
        }

        self.callWindow.rootViewController = self.callWindow.callVC;
        
        [self.callWindow makeKeyAndVisible];
        
        [self notifyUserWithCall:call];
    });
    
}

- (void)notifyUserWithCall:(NXMCall *)call {
    if([UIApplication.sharedApplication applicationState] != UIApplicationStateActive) {
        UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
        
        notificationContent.title = @"Incoming Call";
        NSString *message = @"From: \n";
        for (NXMCallMember* member in call.otherCallMembers) {
            NSString *displayName = member.user.name ? [NTAUserInfoProvider getUserInfoForCSUserName:member.user.name].displayName : nil;
            displayName = [displayName stringByAppendingString:@"\n"];
            message = [message stringByAppendingString:displayName ? displayName : @""];
        }
        
        notificationContent.body = message;
        notificationContent.sound = [UNNotificationSound defaultSound];
        notificationContent.badge = @(1);
        
        UNNotificationTrigger *notificationTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        
        NSString *notificationIdentifier = [[NSUUID UUID] UUIDString];
        UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:notificationIdentifier content:notificationContent trigger:notificationTrigger];
        
        [NTALogger info:@"MainFlow - notifying user for incoming call"];

        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
            if(error) {
                [NTALogger errorWithFormat:@"Failed firing local notification with error: %@", error];
            }
        }];
    }
}

- (void)callEnded:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callWindow.callVC = nil;
        [self.appWindow makeKeyAndVisible];
    });
}

@end
