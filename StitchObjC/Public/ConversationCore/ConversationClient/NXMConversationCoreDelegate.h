//
//  NXMConversationCoreDelegate.h
//  StitchObjC
//
//  Created by Chen Lev on 7/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationEvents.h"

@protocol NXMConversationCoreDelegate <NSObject>

- (void)connectedWithUser:(NXMUser *_Nonnull)user;
//- (void)connectionStatusChange:(NXMConnectionStatus *_Nonnull)status;

- (void)memberJoined:(nonnull NXMMemberEvent *)member;
- (void)memberInvited:(nonnull NXMMemberEvent *)member;
- (void)memberRemoved:(nonnull NXMMemberEvent *)member;

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent;

- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent;
- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent;

- (void)imageRecieved:(nonnull NXMImageEvent *)textEvent;
- (void)imageDeleted:(nonnull NXMTextStatusEvent *)textEvent;
- (void)imageDelivered:(nonnull NXMTextStatusEvent *)textEvent;
- (void)imageSeen:(nonnull NXMTextStatusEvent *)textEvent;

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent;
- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent;
- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent;
- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent;

- (void)mediaChanged:(nonnull NXMMediaEvent *)mediaEvent;

- (void)localMediaChanged:(nonnull NXMMediaEvent *)mediaEvent;
@end