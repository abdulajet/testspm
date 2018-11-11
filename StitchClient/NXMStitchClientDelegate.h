//
//  NXMStitchClientDelegate.h
//  StitcClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StitchCore/StitchCore.h>

@class NXMCall;
@class NXMConversation;

@protocol NXMStitchClientDelegate

- (void)connectionStatusChanged:(BOOL)isOnline;
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;

@optional
- (void)incomingCall:(nonnull NXMCall *)call;
- (void)invitedToConversation:(nonnull NXMConversation *)conversation;

@end
