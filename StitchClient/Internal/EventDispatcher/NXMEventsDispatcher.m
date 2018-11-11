//
//  NXMEventsDispatcher.m
//  StitchObjC
//
//  Created by Doron Biaz on 9/5/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEventsDispatcher.h"

@implementation NXMEventsDispatcher
- (instancetype)init
{
    self = [super init];
    if (self) {
        _notificationCenter = [NSNotificationCenter new];
    }
    return self;
}

-(void)dispatchWithNotificationName:(NSString *)notificationName andEvent:(NXMEvent *)event {
    [self dispatchWithNotificationName:notificationName andUserInfo:[NXMEventsDispatcherNotificationHelper<NXMEvent *> notificationUserInfoWithNotificationModel:event]];
}

-(void)dispatchWithNotificationName:(NSString *)notificationName andUserInfo:(NSDictionary *)userInfo {
    [self.notificationCenter postNotificationName:notificationName object:self userInfo:userInfo];
}


#pragma mark - NXMConversationCoreDelegate
- (void)imageDelivered:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMessageStatus andEvent:statusEvent];
}

- (void)imageSeen:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMessageStatus andEvent:statusEvent];

}

- (void)imageRecieved:(nonnull NXMImageEvent *)imageEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMessage andEvent:imageEvent];

}

- (void)informOnMedia:(nonnull NXMMediaEvent *)mediaEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMedia andEvent:mediaEvent];

}

- (void)actionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMedia andEvent:mediaActionEvent];
}

- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMedia andEvent:sipEvent];
}

- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMedia andEvent:sipEvent];
}

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMedia andEvent:sipEvent];
}

- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMedia andEvent:sipEvent];
}

- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMember andEvent:memberEvent];
}

- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMember andEvent:memberEvent];
}

- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMember andEvent:memberEvent];
}

- (void)textDelivered:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMessage andEvent:statusEvent];
}

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMessage andEvent:textEvent];
}

- (void)textSeen:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMessage andEvent:statusEvent];
}

- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textTypingEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationTyping andEvent:textTypingEvent];
}

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textTypingEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationTyping andEvent:textTypingEvent];
}

- (void)messageDeleted:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationMessage andEvent:statusEvent];
}

- (void)localActionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent {
    //TODO: 🐶
}

- (void)localInformOnMedia:(nonnull NXMMediaEvent *)mediaEvent {
    //TODO: 🐶
}

- (void)connectionStatusChanged:(BOOL)isOnline {
    NXMEventsDispatcherConnectionStatusModel *model = [[NXMEventsDispatcherConnectionStatusModel alloc] initWithIsConnected:isOnline];
    
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationConnectionStatus andUserInfo:[NXMEventsDispatcherNotificationHelper<NXMEventsDispatcherConnectionStatusModel *> notificationUserInfoWithNotificationModel:model]];
}


- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error {
    NXMEventsDispatcherLoginStatusModel *model = [[NXMEventsDispatcherLoginStatusModel alloc] initWithNXMuser:user isLoggedIn:isLoggedIn andError:error];
    
    [self dispatchWithNotificationName:kNXMEventsDispatcherNotificationLoginStatus andUserInfo:[NXMEventsDispatcherNotificationHelper<NXMEventsDispatcherLoginStatusModel *> notificationUserInfoWithNotificationModel:model]];
}


@end