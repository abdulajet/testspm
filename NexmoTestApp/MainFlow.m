//
//  MainFlow.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/20/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "MainFlow.h"
#import "CallViewController.h"
#import "CommunicationsManager.h"
#import "NTAUserInfoProvider.h"
#import "InAppCallCreator.h"
#import "IncomingCallCreator.h"
#import "CallsDefine.h"


@interface CallsWindow : UIWindow

@property (strong, nonatomic) CallViewController *callVC;

@end

@implementation CallsWindow

@end

@interface MainFlow() <CommunicationsManagerObserver>

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
    [[CommunicationsManager sharedInstance] subscribeToNotificationsWithObserver:self]; // incomingCall
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callEnded:) name:kNTACallsDefineNotificationNameEndCall object:nil]; //callEnd
    [self.appWindow makeKeyAndVisible];
}

- (void)incomingCall:(NXMCall *)call {
    dispatch_async(dispatch_get_main_queue(), ^{

        if (self.callWindow.callVC != nil) {
            return;
        }
        
        NTAUserInfo *userInfo  = [NTAUserInfoProvider getUserInfoForCSUserName:call.otherParticipants[0].userName];
        
        IncomingCallCreator *creator = [[IncomingCallCreator alloc] initWithCall:call];
        self.callWindow.callVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Call"];
        [self.callWindow.callVC  updateWithContactUserInfo:userInfo callCreator:creator andIsIncomingCall:YES];

        self.callWindow.rootViewController = self.callWindow.callVC;
        
        [self.callWindow makeKeyAndVisible];
    });
    
}

- (void)callEnded:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callWindow.callVC = nil;
        [self.appWindow makeKeyAndVisible];
    });
}

@end
