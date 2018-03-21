//
//  NXMSocketClientDelegate.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NexmoConversationObjC.h"
#import "NXMMemberEvent.h"

@protocol NXMSocketClientDelegate

- (void)connectionStatusChanged:(BOOL)isOpen;
- (void)userStatusChanged:(nullable NXMUser *)isLoggedIn;

- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent;
- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent;

- (void)messageReceived:(nonnull NXMTextEvent *)message;
- (void)messageSent:(nonnull NXMTextEvent *)message;

@end
