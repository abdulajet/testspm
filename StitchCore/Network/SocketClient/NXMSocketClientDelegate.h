//
//  NXMSocketClientDelegate.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationEvents.h"

@protocol NXMSocketClientDelegate

- (void)connectionStatusChanged:(BOOL)isOpen;
- (void)didLogout:(NXMUser *)user;
- (void)didSuccessfulAuthorization:(NXMUser *)user sessionId:(NSString *)sessionId;
- (void)didFailedAuthorization:(NSError *)error;

- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent;

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent;
- (void)textDelivered:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)textSeen:(nonnull NXMMessageStatusEvent *)statusEvent;

- (void)imageRecieved:(nonnull NXMImageEvent *)imageEvent;
- (void)imageDelivered:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)imageSeen:(nonnull NXMMessageStatusEvent *)statusEvent;

- (void)messageDeleted:(nonnull NXMMessageStatusEvent *)messageEvent;

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textTypingEvent;
- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textTypingEvent;

- (void)mediaEvent:(nonnull NXMMediaEvent *)mediaEvent;
- (void)mediaActionEvent:(nonnull NXMMediaActionEvent *)mediaActionEvent;
- (void)rtcAnswerEvent:(nonnull NXMRtcAnswerEvent *)rtcEvent;

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent;
- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent;
- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent;
- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent;

@end