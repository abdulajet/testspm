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
#import "NXMTextStatusEvent.h"
#import "NXMTextTypingEvent.h"
#import "NXMAddUserRequest.h"
#import "NXMGetConversationsRequest.h"
#import "NXMDeleteEventRequest.h"
#import "NXMSendTextEventRequest.h"
#import "NXMInviteUserRequest.h"
#import "NXMJoinMemberRequest.h"
#import "NXMRemoveMemberRequest.h"
#import "NXMCreateConversationRequest.h"

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

#pragma mark - StitchConversationClientCore

/** ---------------------------------------------------------------------------------------
 * @name StitchConversationClientCore SDK Integration
 *  ---------------------------------------------------------------------------------------
 */
@interface StitchConversationClientCore:NSObject

- (instancetype _Nullable)initWithConfig:(nonnull NXMConversationClientConfig *)config; // TODO: can update config?
- (void)enablePushNotifications:(BOOL)enable responseBlock:(void (^_Nullable)(NSError * _Nullable error))responseBlock;
- (void)loginWithToken:(nonnull NSString *)token;
- (void)logout:(void (^_Nullable)(NSError * _Nullable error))responseBlock;

- (void)createConversation:(nonnull NXMCreateConversationRequest *)createConversationRequest
        responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable conversation))responseBlock;

- (void)addUserToConversation:(nonnull NXMAddUserRequest*)addUserRequest
              completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)inviteUserToConversation:(nonnull NXMInviteUserRequest *)inviteUserRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)joinMemberToConversation:(nonnull NXMJoinMemberRequest *)joinMemberRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)removeMemberFromConversation:(nonnull NXMRemoveMemberRequest *)removeMemberRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)sendText:(nonnull NXMSendTextEventRequest *)sendTextEventRequest
        completionHandler:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable textId))completionHandler;

- (void)deleteText:(nonnull NXMDeleteEventRequest *)deleteEventRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)getConversationDetails:(nonnull NSString*)conversationId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMConversationDetails * _Nullable data))completionBlock;

- (void)getConversations:( NXMGetConversationsRequest* _Nullable )getConversationsRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMConversationDetails*> * _Nullable data))completionBlock;


- (void)getUser:(nonnull NSString*)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMUser * _Nullable data))completionBlock;

- (BOOL)enableAudio:(nonnull NSString *)conversationID;
- (BOOL)disableAudio:(nonnull NSString *)conversationID;

- (nonnull NXMConnectionStatus *)getConnectionStatus;
- (nonnull NXMUser *)getUser;
- (nonnull NSString *)getToken;
- (BOOL)isLoggedIn; // TODO: the use already login but the network is down?

- (void)registerEventsWithDelegate:(nonnull id<NXMConversationClientDelegate>)delegate;
- (void)unregisterEvents;

- (void)seenTextEvent:(nonnull NSString *)conversationId
             memberId:(nonnull NSString *)memberId
              eventId:(nonnull NSString *)eventId;


- (void)deliverTextEvent:(nonnull NSString *)conversationId
                memberId:(nonnull NSString *)memberId
                 eventId:(nonnull NSString *)eventId;

- (void)textTypingOnEvent:(nonnull NSString *)conversationId
            memberId:(nonnull NSString *)memberId;

- (void)textTypingOffEvent:(nonnull NSString *)conversationId
             memberId:(nonnull NSString *)memberId;


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
- (void)textRecieved:(nonnull NXMTextEvent *)textEvent;
- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent;
- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent;
- (void)messageReceived:(nonnull NXMTextEvent *)message;
- (void)messageSent:(nonnull NXMTextEvent *)message;
@end







