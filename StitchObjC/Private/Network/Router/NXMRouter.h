//
//  NXMRouter.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMNetworkCallbacks.h"

#import "NXMConversationDetails.h"
#import "NXMAddUserRequest.h"
#import "NXMInviteUserRequest.h"
#import "NXMInvitePstnRequest.h"
#import "NXMInvitePstnKnockingRequest.h"
#import "NXMJoinMemberRequest.h"
#import "NXMRemoveMemberRequest.h"
#import "NXMSendTextEventRequest.h"
#import "NXMDeleteEventRequest.h"
#import "NXMGetConversationsRequest.h"
#import "NXMCreateConversationRequest.h"
#import "NXMSendImageRequest.h"
#import "NXMGetEventsRequest.h"
#import "NXMEnablePushRequest.h"


@interface NXMRouter : NSObject

- (nullable instancetype)initWitHost:(nonnull NSString *)host;

- (void)setToken:(nonnull NSString *)token;

- (void)setSessionId:(nonnull NSString *)sessionId;

- (void)enablePushNotifications:(nonnull NXMEnablePushRequest *)request
                      onSuccess:(SuccessCallback _Nullable)onSuccess
                        onError:(ErrorCallback _Nullable)onError;

- (void)createConversation:(nonnull NXMCreateConversationRequest*)createConversationRequest
                 onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                   onError:(ErrorCallback _Nullable)onError;

- (void)addUserToConversation:(nonnull NXMAddUserRequest*)addUserRequest
                    onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                      onError:(ErrorCallback _Nullable)onError;

- (void)inviteUserToConversation:(nonnull NXMInviteUserRequest *)inviteUserRequest
                       onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                         onError:(ErrorCallback _Nullable)onError;

- (void)invitePstnToConversation:(nonnull NXMInvitePstnRequest *)invitePstnRequest
                       onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                         onError:(ErrorCallback _Nullable)onError;

- (void)invitePstnKnockingToConversation:(nonnull NXMInvitePstnKnockingRequest *)invitePstnRequest
                       onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                         onError:(ErrorCallback _Nullable)onError;

- (void)joinMemberToConversation:(nonnull NXMJoinMemberRequest *)joinMembetRequest
                       onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                         onError:(ErrorCallback _Nullable)onError;

- (void)removeMemberFromConversation:(nonnull NXMRemoveMemberRequest *)removeMemberRequest
                           onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                             onError:(ErrorCallback _Nullable)onError;

- (void)sendTextToConversation:(nonnull NXMSendTextEventRequest*)sendTextEventRequest
                     onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                       onError:(ErrorCallback _Nullable)onError;

- (void)sendImage:(nonnull NXMSendImageRequest *)sendImageRequest
        onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
          onError:(ErrorCallback _Nullable)onError;

- (void)deleteEventFromConversation:(nonnull NXMDeleteEventRequest*)deleteEventRequest
                         onSuccess:(SuccessCallback _Nullable)onSuccess
                           onError:(ErrorCallback _Nullable)onError;

- (void)getConversations:(nonnull NXMGetConversationsRequest*)getConvetsationsRequest
               onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                 onError:(ErrorCallback _Nullable)onError;

- (void)getEvents:(nonnull NXMGetEventsRequest*)getEventsRequest
        onSuccess:(SuccessCallbackWithEvents _Nullable)onSuccess
          onError:(ErrorCallback _Nullable)onError;

- (void)getConversationDetails:(nonnull NSString*)conversationId
                     onSuccess:(SuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(ErrorCallback _Nullable)onError;

- (void)getUserConversations:(nonnull NSString *)userId
                   onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                     onError:(ErrorCallback _Nullable)onError;

- (void)getUser:(nonnull NSString*)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMUser * _Nullable data))completionBlock;

- (void)enableMedia:(nonnull NSString *)conversationId
           memberId:(nonnull NSString *)memberId
                sdp:(nonnull NSString *)sdp
          mediaType:(nonnull NSString *)mediaType // TODO: enum
          onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
            onError:(ErrorCallback _Nullable)onError;

- (void)disableMedia:(nonnull NSString *)conversationId
               rtcId:(nonnull NSString *)rtcId
            memberId:(nonnull NSString *)memberId
           onSuccess:(SuccessCallback _Nullable)onSuccess
             onError:(ErrorCallback _Nullable)onError;
@end
