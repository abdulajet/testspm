//
//  NXMNetworkDelegate.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 5/23/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCoreEvents.h"

@protocol NXMNetworkDelegate

- (NSString *)authToken;

- (void)connectionStatusChanged:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason;
- (void)userChanged:(NXMUser *)user;

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent;
- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent;
- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent;
- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent;

- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent;

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent;
- (void)textDelivered:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)textSeen:(nonnull NXMMessageStatusEvent *)statusEvent;

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textTypingEvent;
- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textTypingEvent;

- (void)imageRecieved:(nonnull NXMImageEvent *)textEvent;
- (void)imageDelivered:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)imageSeen:(nonnull NXMMessageStatusEvent *)statusEvent;

- (void)messageDeleted:(nonnull NXMMessageStatusEvent *)messageEvent;

- (void)mediaEvent:(nonnull NXMMediaEvent *)mediaEvent;
- (void)mediaActionEvent:(nonnull NXMMediaActionEvent *)mediaActionEvent;

- (void)rtcAnswerEvent:(nonnull NXMRtcAnswerEvent *)rtcEvent;
- (void)DTMFEvent:(nonnull NXMDTMFEvent *)dtmfEvent;


@end
