//
//  NXMStitchCoreDelegate.h
//  StitchCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCoreEvents.h"

@protocol NXMStitchCoreDelegate

#pragma mark - user status

- (void)connectionStatusChanged:(BOOL)isOnline;
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;
- (void)tokenRefreshed;

@optional
#pragma mark - member events
- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent;

#pragma mark - messages events

- (void)messageDeleted:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)textRecieved:(nonnull NXMTextEvent *)textEvent;
- (void)textDelivered:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)textSeen:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textTypingEvent;
- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textTypingEvent;

- (void)imageRecieved:(nonnull NXMImageEvent *)imageEvent;
- (void)imageDelivered:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)imageSeen:(nonnull NXMMessageStatusEvent *)statusEvent;

#pragma mark - media events

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent;
- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent;
- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent;
- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent;

- (void)informOnMedia:(nonnull NXMMediaEvent *)mediaEvent;
- (void)actionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent;

- (void)localInformOnMedia:(nonnull NXMMediaEvent *)mediaEvent;
- (void)localActionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent;
@end

