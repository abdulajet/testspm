//
//  NXMNetworkManager.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMNetworkCallbacks.h"
#import "NXMNetworkDelegate.h"

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

@interface NXMNetworkManager : NSObject

- (nullable instancetype)initWitHost:(nonnull NSString *)httpHost andWsHost:(nonnull NSString *)wsHost;

- (void)setDelegate:(nonnull id<NXMNetworkDelegate>)delegate;

- (void)loginWithToken:(NSString * _Nonnull)token
             onSuccess:(SuccessCallbackWithObject _Nullable)onSuccess
               onError:(ErrorCallback _Nullable)onError;

- (void)logout;

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

- (void)seenTextEvent:(nonnull NSString *)conversationId
             memberId:(nonnull NSString *)memberId
              eventId:(NSInteger)eventId;


- (void)deliverTextEvent:(nonnull NSString *)conversationId
                memberId:(nonnull NSString *)memberId
                 eventId:(NSInteger)eventId;

- (void)textTypingOn:(nonnull NSString *)conversationId
            memberId:(nonnull NSString *)memberId;

- (void)textTypingOff:(nonnull NSString *)conversationId
             memberId:(nonnull NSString *)memberId;

- (void)getConversations:(nonnull NXMGetConversationsRequest*)getConvetsationsRequest
               onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                 onError:(ErrorCallback _Nullable)onError;

- (void)getEvents:(nonnull NXMGetEventsRequest *)getEventsRequest
        onSuccess:(SuccessCallbackWithEvents _Nullable)onSuccess
          onError:(ErrorCallback _Nullable)onError;
        
- (void)getConversationDetails:(nonnull NSString*)conversationId
                     onSuccess:(SuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(ErrorCallback _Nullable)onError;

- (void)getUserConversations:(nonnull NSString *)userId
                   onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                     onError:(ErrorCallback _Nullable)onError;

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
