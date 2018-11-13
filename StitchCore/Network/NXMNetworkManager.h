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
#import "NXMSocketClientDelegate.h"


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
#import "NXMSuspendResumeMediaRequest.h"


@interface NXMNetworkManager : NSObject <NXMSocketClientDelegate>

- (nullable instancetype)initWithHost:(nonnull NSString *)httpHost andWsHost:(nonnull NSString *)wsHost;

- (void)setDelegate:(nonnull id<NXMNetworkDelegate>)delegate;

- (void)loginWithToken:(NSString * _Nonnull)token;

- (void)logout;

- (void)enablePushNotifications:(nonnull NXMEnablePushRequest *)request
                      onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                        onError:(NXMErrorCallback _Nullable)onError;

- (void)disablePushNotificationsWithOnSuccess:(NXMSuccessCallback _Nullable)onSuccess
                        onError:(NXMErrorCallback _Nullable)onError;

- (void)createConversation:(nonnull NXMCreateConversationRequest*)createConversationRequest
                 onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                   onError:(NXMErrorCallback _Nullable)onError;

- (void)addUserToConversation:(nonnull NXMAddUserRequest*)addUserRequest
                    onSuccess:(NXMSuccessCallbackWithObject _Nullable)onSuccess
                      onError:(NXMErrorCallback _Nullable)onError;

- (void)inviteUserToConversation:(nonnull NXMInviteUserRequest *)inviteUserRequest
                       onSuccess:(NXMSuccessCallbackWithObject _Nullable)onSuccess
                         onError:(NXMErrorCallback _Nullable)onError;

- (void)invitePstnToConversation:(nonnull NXMInvitePstnRequest *)invitePstnRequest
                       onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                         onError:(NXMErrorCallback _Nullable)onError;

- (void)invitePstnKnockingToConversation:(nonnull NXMInvitePstnKnockingRequest *)invitePstnRequest
                       onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                         onError:(NXMErrorCallback _Nullable)onError;

- (void)joinMemberToConversation:(nonnull NXMJoinMemberRequest *)joinMembetRequest
                       onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                         onError:(NXMErrorCallback _Nullable)onError;

- (void)removeMemberFromConversation:(nonnull NXMRemoveMemberRequest *)removeMemberRequest
                           onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                             onError:(NXMErrorCallback _Nullable)onError;

- (void)sendTextToConversation:(nonnull NXMSendTextEventRequest*)sendTextEventRequest
                     onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                       onError:(NXMErrorCallback _Nullable)onError;

- (void)sendImage:(nonnull NXMSendImageRequest *)sendImageRequest
        onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
          onError:(NXMErrorCallback _Nullable)onError;

- (void)deleteEventFromConversation:(nonnull NXMDeleteEventRequest*)deleteEventRequest
                         onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                           onError:(NXMErrorCallback _Nullable)onError;

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
               onSuccess:(NXMSuccessCallbackWithConversations _Nullable)onSuccess
                 onError:(NXMErrorCallback _Nullable)onError;

- (void)getEvents:(nonnull NXMGetEventsRequest *)getEventsRequest
        onSuccess:(NXMSuccessCallbackWithEvents _Nullable)onSuccess
          onError:(NXMErrorCallback _Nullable)onError;
        
- (void)getConversationDetails:(nonnull NSString*)conversationId
                     onSuccess:(NXMSuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(NXMErrorCallback _Nullable)onError;

- (void)getConversationsForUser:(nonnull NSString *)userId
                   onSuccess:(NXMSuccessCallbackWithConversations _Nullable)onSuccess
                     onError:(NXMErrorCallback _Nullable)onError;

- (void)enableMedia:(nonnull NSString *)conversationId
           memberId:(nonnull NSString *)memberId
                sdp:(nonnull NSString *)sdp
          mediaType:(nonnull NSString *)mediaType // TODO: enum
          onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
            onError:(NXMErrorCallback _Nullable)onError;

- (void)disableMedia:(nonnull NSString *)conversationId
               rtcId:(nonnull NSString *)rtcId
            memberId:(nonnull NSString *)memberId
           onSuccess:(NXMSuccessCallback _Nullable)onSuccess
             onError:(NXMErrorCallback _Nullable)onError;

- (void)suspendMediaWithMediaRequest:(nonnull NXMSuspendResumeMediaRequest *)mediaRequest
                 onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                   onError:(NXMErrorCallback _Nullable)onError;

- (void)resumeMediaWithMediaRequest:(nonnull NXMSuspendResumeMediaRequest *)mediaRequest
                onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                  onError:(NXMErrorCallback _Nullable)onError;

@end
