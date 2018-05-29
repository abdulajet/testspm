//
//  AppDelegate.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, readwrite, strong) StitchConversationClientCore *stitchConversation;

@end

@implementation AppDelegate

- (void)setStitch:(StitchConversationClientCore *)stitch {
    self.stitchConversation = stitch;
    [self.stitchConversation setDelgate:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)connectedWithUser:(NXMUser *_Nonnull)user {
    
}

- (void)connectionStatusChange:(NXMConnectionStatus *_Nonnull)status {
    
}

- (void)memberJoined:(nonnull NXMMemberEvent *)member {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"memberEvent"
     object:nil userInfo:@{@"member":member}];
}

- (void)memberLeft:(nonnull NXMMemberEvent *)member {
    
}

- (void)memberInvited:(nonnull NXMMemberEvent *)member byMember:(nonnull NSString *)memberId {
    
}

- (void)memberRemoved:(nonnull NXMMemberEvent *)member {
    
}

- (void)imageRecieved:(nonnull NXMTextEvent *)textEvent {
    
}


- (void)localMediaChanged:(nonnull NXMMediaEvent *)mediaEvent {
    
}


- (void)mediaChanged:(nonnull NXMMediaEvent *)mediaEvent {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"mediaEvent"
     object:nil userInfo:@{@"media":mediaEvent}];
}


- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent {
    
}


- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent {
    
}


- (void)textRecieved:(nonnull NXMTextEvent *)textEvent {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"textEvent"
     object:nil userInfo:@{@"text":textEvent}];
}


- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent {
    
}


- (void)textSent:(nonnull NXMTextStatusEvent *)textEvent {
    
}


- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent {
    
}


- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent {
    
}


//- (void)textRecieved:(nonnull NXMTextEvent *)textEvent;
//- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent;
//- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent;
//- (void)textSent:(nonnull NXMTextStatusEvent *)textEvent;
//- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent;
//- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent;
//- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent;
//
//- (void)imageRecieved:(nonnull NXMTextEvent *)textEvent;
//- (void)mediaChanged:(nonnull NXMMediaEvent *)mediaEvent;
//
//- (void)localMediaChanged:(nonnull NXMMediaEvent *)mediaEvent;

@end
