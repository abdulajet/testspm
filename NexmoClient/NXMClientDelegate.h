//
//  NXMClientDelegate.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMUser.h"

@class NXMCall;
@class NXMConversation;

@protocol NXMClientDelegate <NSObject>

- (void)connectionStatusChanged:(BOOL)isOnline;
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;
- (void)tokenRefreshed;

@optional
- (void)incomingCall:(nonnull NXMCall *)call;
- (void)addedToConversation:(nonnull NXMConversation *)conversation;

@end
