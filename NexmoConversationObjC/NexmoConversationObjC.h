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
@class NXMConnectionStatus;
@class NXMTextEvent;


#import "NXMConversationDetails.h"
#import "NXMUser.h"
#import "NXMMember.h"

#pragma mark - SDK Integration

#pragma mark - NXMConfig
/** ---------------------------------------------------------------------------------------
 * @name NXMConfig SDK Integration
 *  ---------------------------------------------------------------------------------------
 */

@interface NXMConversationClientConfig : NSObject

- (nonnull NSString *)getWSHost;
- (nonnull NSString *)getHttpHost;

@end

#pragma mark - NXMConversationClient

/** ---------------------------------------------------------------------------------------
 * @name NXMConversationClient SDK Integration
 *  ---------------------------------------------------------------------------------------
 */
@interface NXMConversationClient:NSObject

- (instancetype _Nullable)initWithConfig:(nonnull NXMConversationClientConfig *)config; // TODO: can update config?
- (void)enablePushNotifications:(BOOL)enable responseBlock:(void (^_Nullable)(NSError * _Nullable error))responseBlock;
- (void)loginWithToken:(nonnull NSString *)token;
- (void)logout:(void (^_Nullable)(NSError * _Nullable error))responseBlock;

- (void)newConversationWithConversationName:(nonnull NSString *)conversationName responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable conversation))responseBlock;

- (void)addUserToConversation:(nonnull NSString *)conversationId
                         userId:(nonnull NSString *)userId
                completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock;

- (void)joinMemberToConverstion:(nonnull NSString *)conversationId
                         memberId:(nonnull NSString *)memberId
                completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock;

- (void)inviteMemberToConverstion:(nonnull NSString *)conversationId
                         memberId:(nonnull NSString *)memberId
                  completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock;

- (void)removeMemberFromConversation:(nonnull NSString *)conversationId
                           memberId:(nonnull NSString *)memberId
                    completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock;

- (void)sendText:(nonnull NSString *)text
    conversationId:(nonnull NSString *)conversationId
    fromMemberId:(nonnull NSString *)fromMemberId
    completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock;

- (nullable NXMConversationDetails *)getConversationWithCID:(nonnull NSString *)cid;
- (nullable NSArray<NXMConversationDetails *> *)getConversationList; // TODO: async?

- (void)enableAudio:(nonnull NSString *)conversationID;
- (void)disableAudio:(nonnull NSString *)conversationID;

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

- (void)connectedWithUser:(NXMUser *_Nonnull)user;
- (void)connectionStatusChange:(NXMConnectionStatus *_Nonnull)status;

- (void)incomingCallWithConversation:(nonnull NXMConversationDetails *)conversation;
- (void)joinedToNewConversationEvent:(nonnull NXMConversationDetails *)conversation;

- (void)memberJoined:(nonnull NXMMember *)member;
- (void)memberLeft:(nonnull NXMMember *)member;
- (void)memberInvited:(nonnull NXMMember *)member byMember:(nonnull NSString *)memberId;
- (void)memberRemoved:(nonnull NXMMember *)member;

- (void)messageReceived:(nonnull NXMTextEvent *)message;
- (void)messageSent:(nonnull NXMTextEvent *)message;
@end







