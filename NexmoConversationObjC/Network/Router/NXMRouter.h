//
//  NXMRouter.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMMember.h"
#import "NXMConversationDetails.h"
#import "NXMAddUserRequest.h"
#import "NXMInviteUserRequest.h"
#import "NXMJoinMemberRequest.h"
#import "NXMRemoveMemberRequest.h"
#import "NXMSendTextEventRequest.h"
#import "NXMDeleteEventRequest.h"
#import "NXMGetConversationsRequest.h"
#import "NXMCreateConversationRequest.h"


@interface NXMRouter : NSObject

- (nullable instancetype)initWitHost:(nonnull NSString *)host;

- (void)setToken:(nonnull NSString *)token;

- (void)createConversation:(nonnull NXMCreateConversationRequest*)createConversationRequest
        responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable  conversationId))responseBlock;

- (void)addUserToConversation:(nonnull NXMAddUserRequest*)addUserRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary *_Nullable data))compeltionBlock;

- (void)inviteUserToConversation:(nonnull NXMInviteUserRequest *)inviteUserRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)joinMemberToConversation:(nonnull NXMJoinMemberRequest *)joinMembetRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)removeMemberFromConversation:(nonnull NXMRemoveMemberRequest *)removeMemberRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)sendTextToConversation:(nonnull NXMSendTextEventRequest*)sendTextEventRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)deleteTextFromConversation:(nonnull NXMDeleteEventRequest*)deleteEventRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (void)getConversations:(nonnull NXMGetConversationsRequest*)getConvetsationsRequest
         completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMConversationDetails *>* _Nullable data))completionBlock;

- (void)getConversationDetails:(nonnull NSString*)conversationId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMConversationDetails * _Nullable data))completionBlock;

- (void)getUser:(nonnull NSString*)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMUser * _Nullable data))completionBlock;

- (void)requestToServer:(nonnull NSDictionary*)dict url:(nonnull NSURL*)url httpMethod:(nonnull NSString*)httpMethod
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

@end
