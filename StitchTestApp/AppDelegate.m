//
//  AppDelegate.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, readwrite, strong) NXMConversationCore *stitchConversation;
@property (nonatomic, readwrite, strong) NSMutableDictionary *conversationIdToMemberId;
@property (nonatomic, readwrite, strong) NSData *deviceToken;

@end

@implementation AppDelegate

- (void)setStitch:(NXMConversationCore *)stitch {
    self.stitchConversation = stitch;
    [self.stitchConversation setDelgate:self];
}

- (void)addConversationMember:(NSString *)conv  memberId:(NSString *)memberId {
    [self.conversationIdToMemberId setObject:memberId forKey:conv];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.conversationIdToMemberId = [NSMutableDictionary new];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                NSLog( @"Push registration success." );
            } else {
                NSLog( @"Push registration FAILED" );
                NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
            }});
    }];

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

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.deviceToken = deviceToken;
    NSLog( @"Push registration didRegisterForRemoteNotificationsWithDeviceToken" );
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSLog( @"Handle push from foreground" );
    // custom code to handle push while app is in the foreground
    NSLog(@"%@", notification.request.content.userInfo);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
{
    NSLog( @"Handle push from background or closed" );
    // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
    NSLog(@"%@", response.notification.request.content.userInfo);
}

#pragma mark - StitchDelegate

- (void)connectedWithUser:(NXMUser *_Nonnull)user {
    
}

//- (void)connectionStatusChange:(NXMConnectionStatus *_Nonnull)status {
//    
//}

- (void)memberJoined:(nonnull NXMMemberEvent *)member {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"memberEvent"
     object:nil userInfo:@{@"member":member}];
}

- (void)memberLeft:(nonnull NXMMemberEvent *)member {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"memberEvent"
     object:nil userInfo:@{@"member":member}];
}

- (void)memberInvited:(nonnull NXMMemberEvent *)member {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"memberEvent"
     object:nil userInfo:@{@"member":member}];
}

- (void)memberRemoved:(nonnull NXMMemberEvent *)member {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"memberEvent"
     object:nil userInfo:@{@"member":member}];
}

- (void)localMediaChanged:(nonnull NXMMediaEvent *)mediaEvent {
    
}


- (void)mediaChanged:(nonnull NXMMediaEvent *)mediaEvent {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"mediaEvent"
     object:nil userInfo:@{@"media":mediaEvent}];
}


- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"textStatusEvent"
     object:nil userInfo:@{@"textEvent":textEvent}];
}


- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"textStatusEvent"
     object:nil userInfo:@{@"textEvent":textEvent}];
}

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sipEvent"
     object:nil userInfo:@{@"sipEvent":sipEvent}];
    
}
- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sipEvent"
     object:nil userInfo:@{@"sipEvent":sipEvent}];
    
}
- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sipEvent"
     object:nil userInfo:@{@"sipEvent":sipEvent}];
    
}
- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sipEvent"
     object:nil userInfo:@{@"sipEvent":sipEvent}];
    
}

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent {
    NSString *memberId = self.conversationIdToMemberId[textEvent.conversationId];
    if (memberId) {
        [self.stitchConversation markAsDelivered:textEvent.sequenceId conversationId:textEvent.conversationId fromMemberWithId:memberId onSuccess:^{
            
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error markAsDelivered");
        }];
    } else {
        [self.stitchConversation getConversationDetails:textEvent.conversationId onSuccess:^(NXMConversationDetails * _Nullable conversationDetails) {
            NSString *currMember;
            for (NXMMember *member in conversationDetails.members) {
                if ([member.userId isEqualToString:self.stitchConversation.getUser.uuid]){
                    currMember = member.memberId;
                    [self.conversationIdToMemberId setObject:member.memberId forKey:member.conversationId];
                    break;
                }
            }
            
            [self.stitchConversation markAsDelivered:textEvent.sequenceId conversationId:textEvent.conversationId fromMemberWithId:currMember onSuccess:^{
                
            } onError:^(NSError * _Nullable error) {
                NSLog(@"error markAsDelivered");
            }];
        } onError:^(NSError * _Nullable error) {
            
        }];
    }
    

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"textEvent"
     object:nil userInfo:@{@"text":textEvent}];
}

- (void)imageRecieved:(nonnull NXMImageEvent *)textEvent {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"imageEvent"
     object:nil userInfo:@{@"image":textEvent}];
}



- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"textStatusEvent"
     object:nil userInfo:@{@"textEvent":textEvent}];
}


- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"typingEvent"
     object:nil userInfo:@{@"typingEvent":textEvent}];
}


- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"typingEvent"
     object:nil userInfo:@{@"typingEvent":textEvent}];
}

- (void)imageDeleted:(nonnull NXMTextStatusEvent *)textEvent {
    
}


- (void)imageDelivered:(nonnull NXMTextStatusEvent *)textEvent {
    
}


- (void)imageSeen:(nonnull NXMTextStatusEvent *)textEvent {
    
}




@end
