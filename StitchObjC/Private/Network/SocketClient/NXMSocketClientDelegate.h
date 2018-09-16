//
//  NXMSocketClientDelegate.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMemberEvent.h"
#import "NXMTextEvent.h"
#import "NXMSipEvent.h"
#import "NXMImageEvent.h"
#import "NXMTextStatusEvent.h"
#import "NXMTextTypingEvent.h"
#import "NXMMediaEvent.h"
#import "NXMMediaActionEvent.h"
#import "NXMRtcAnswerEvent.h"

@protocol NXMSocketClientDelegate

- (void)connectionStatusChanged:(BOOL)isOpen;
- (void)didLogout:(NXMUser *)user;
- (void)didSuccessfulAuthorization:(NXMUser *)user sessionId:(NSString *)sessionId;
- (void)didFailedAuthorization:(NSError *)error;

- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent;

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent;
- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent;

- (void)imageRecieved:(nonnull NXMImageEvent *)textEvent;

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent;
- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent;

- (void)mediaEvent:(nonnull NXMMediaEvent *)mediaEvent;
- (void)mediaActionEvent:(nonnull NXMMediaActionEvent *)mediaEvent;
- (void)rtcAnswerEvent:(nonnull NXMRtcAnswerEvent *)rtcEvent;

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent;
- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent;
- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent;
- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent;

@end
