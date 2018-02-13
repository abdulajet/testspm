//
//  NexmoConversationObjC.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for NexmoConversationObjC.
FOUNDATION_EXPORT double NexmoConversationObjCVersionNumber;

//! Project version string for NexmoConversationObjC.
FOUNDATION_EXPORT const unsigned char NexmoConversationObjCVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NexmoConversationObjC/PublicHeader.h>

@protocol NXMResponseDelegate;
@protocol NXMConversationClientDelegate;
@class NXMConversationClientConfig;
@class NXMConversation;
@class NXMUser;
@class NXMConnectionStatus;

@protocol NXMConversationClient

#pragma mark - SDK Integration
/** ---------------------------------------------------------------------------------------
 * @name NXMConversationClient SDK Integration
 *  ---------------------------------------------------------------------------------------
 */

+ (instancetype _Nullable)initWithConfig:(nonnull NXMConversationClientConfig *)config; // TODO: can update config?
- (void)enablePushNotifications:(BOOL)enable responseBlock:(void (^_Nullable)(NSError * _Nullable error))responseBlock;
- (void)loginWithToken:(nonnull NSString *)token responseBlock:(void (^_Nullable)(NSError * _Nullable error))responseBlock;
- (void)logout:(void (^_Nullable)(NSError * _Nullable error))responseBlock;

- (void)newConversationWithConversationName:(nonnull NSString *)conversationName responseBlock:(void (^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))responseBlock;
- (nullable NXMConversation *)getConversationWithCID:(nonnull NSString *)cid;
- (nullable NSArray<NXMConversation *> *)getConversationList; // TODO: async?

- (nonnull NXMConnectionStatus *)getConnectionStatus;
- (nonnull NXMUser *)getUser;
- (nonnull NSString *)getToken;
- (BOOL)isLoggedIn; // TODO: the use already login but the network is down?

- (void)registerEventsWithDelegate:(nonnull id<NXMConversationClientDelegate>)delegate;
- (void)unregisterEvents;

@end


#pragma mark - NXMConversationClientDelegate
@protocol NXMConversationClientDelegate <NSObject>
/** ---------------------------------------------------------------------------------------
 * @name NXMConversationClientDelegate SDK Integration
 *  ---------------------------------------------------------------------------------------
 */

- (void)incomingCallWithConversation:(nonnull NXMConversation *)conversation;
- (void)joinedToNewConversationEvent:(nonnull NXMConversation *)conversation;



@end


#pragma mark - SDK Conversation Client Config
@protocol NXMConversationClientConfig <NSObject>
/** ---------------------------------------------------------------------------------------
 * @name NXMConversationClientConfig SDK Integration
 *  ---------------------------------------------------------------------------------------
 */


@end


#pragma mark - NXMConversation
@protocol NXMConversation <NSObject>
/** ---------------------------------------------------------------------------------------
 * @name NXMConversation SDK Integration
 *  ---------------------------------------------------------------------------------------
 */

- (void)sync:(void (^_Nullable)(NSError * _Nullable error))responseBlock; // TODO: ?


@end

#pragma mark - NXMוUser
@protocol NXMוUser <NSObject>
/** ---------------------------------------------------------------------------------------
 * @name NXMConversation SDK Integration
 *  ---------------------------------------------------------------------------------------
 */

- (void)sync:(void (^_Nullable)(NSError * _Nullable error))responseBlock; // TODO: ?


@end






