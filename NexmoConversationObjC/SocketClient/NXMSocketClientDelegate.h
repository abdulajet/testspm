//
//  NXMSocketClientDelegate.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NexmoConversationObjC.h"

@protocol NXMSocketClientDelegate

- (void)connectionStatusChanged:(BOOL)isOpen;
- (void)userStatusChanged:(nullable NXMUser *)isLoggedIn;

- (void)memberJoined:(nonnull NXMMember *)member;
- (void)memberRemoved:(nonnull NXMMember *)member;
- (void)memberInvited:(nonnull NXMMember *)member;

- (void)messageReceived:(nonnull NXMTextEvent *)message;
- (void)messageSent:(nonnull NXMTextEvent *)message;

@end
