
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
@class NXMClient;

/**
 The NXMClientDelegate protocol notifies on client updates.
 */
@protocol NXMClientDelegate <NSObject>

/**
 * Connection status changed.
 * @param client A `NXMClient` object.
 * @param status A `NXMConnectionStatus` enum, the updated connection status.
 * @param reason A `NXMConnectionStatusReason` enum, the reason for the update.
 */
- (void)client:(nonnull NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason;

/**
 * Did receive error.
 * @param client A `NXMClient` object.
 * @param error A `NSError` object, the error received.
 */
- (void)client:(nonnull NXMClient *)client didReceiveError:(nonnull NSError *)error;
@optional

/**
 * Did receive a call.
 * @param client A `NXMClient` object.
 * @param call A `NXMCall` object, the call received.
 */
- (void)client:(nonnull NXMClient *)client didReceiveCall:(nonnull NXMCall *)call;

/**
 * Did receive a conversation.
 * @param client A `NXMClient` object.
 * @param conversation A `NXMConversation` object, the conversation received.
 */
- (void)client:(nonnull NXMClient *)client didReceiveConversation:(nonnull NXMConversation *)conversation;

@end
