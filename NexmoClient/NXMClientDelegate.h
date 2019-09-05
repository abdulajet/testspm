//
//  NXMClientDelegate.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMUser.h"
#import "NXMEnums.h"

@class NXMCall;
@class NXMConversation;

@protocol NXMClientDelegate <NSObject>

- (void)didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason;

@optional
- (void)didReceiveCall:(nonnull NXMCall *)call;
- (void)didReceiveConversation:(nonnull NXMConversation *)conversation;

@end
