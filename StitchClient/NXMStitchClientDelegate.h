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

@protocol NXMStitchClientDelegate <NSObject>

- (void)connectionStatusChanged:(BOOL)isOnline;
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;
- (void)tokenRefreshed;

@optional
- (void)incomingCall:(nonnull NXMCall *)call;
- (void)addedToConversation:(nonnull NXMConversation *)conversation;

@end
