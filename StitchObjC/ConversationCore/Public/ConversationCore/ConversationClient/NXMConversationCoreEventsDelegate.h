//
//  NXMConversationCoreEventsDelegate.h
//  StitchObjC
//
//  Created by Doron Biaz on 9/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationEvents.h"

@protocol NXMConversationCoreEventsDelegate <NSObject>
- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent;


- (void)messageDeleted:(nonnull NXMMessageStatusEvent *)statusEvent;

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent;
- (void)textDelivered:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)textSeen:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textTypingEvent;
- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textTypingEvent;

- (void)imageRecieved:(nonnull NXMImageEvent *)imageEvent;
- (void)imageDelivered:(nonnull NXMMessageStatusEvent *)statusEvent;
- (void)imageSeen:(nonnull NXMMessageStatusEvent *)statusEvent;

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent;
- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent;
- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent;
- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent;

- (void)informOnMedia:(nonnull NXMMediaEvent *)mediaEvent;
- (void)actionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent;

- (void)localInformOnMedia:(nonnull NXMMediaEvent *)mediaEvent;
- (void)localActionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent;
@end
