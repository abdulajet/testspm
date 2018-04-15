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


@interface NXMRouter : NSObject

- (nullable instancetype)initWitHost:(nonnull NSString *)host;

- (void)setToken:(nonnull NSString *)token;

- (BOOL)createConversationWithName:(nonnull NSString *)name
        responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable conversationId))responseBlock;

- (BOOL)addUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (BOOL)inviteUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (BOOL)joinMemberToConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (BOOL)removeMemberFromConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (BOOL)sendTextToConversation:(nonnull NSString*)convesationId memberId:(nonnull NSString*)memberId textToSend:(nonnull NSString*)textTeSend
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (BOOL)deleteTextFromConversation:(nonnull NSString*)convesationId memberId:(nonnull NSString*)memberId eventId:(nonnull NSString*)eventId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

- (BOOL)getConversation:(nonnull NSString*)conversationId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMConversationDetails * _Nullable data))completionBlock;

- (BOOL)getNumOfConversations:(void (^_Nullable)(NSError * _Nullable error, long * _Nullable data)) completionBlock;

- (BOOL)getConversationsPaging:( NSString* _Nullable )name dateStart:( NSString* _Nullable )dateStart  dateEnd:( NSString* _Nullable )dateEnd pageSize:(long)pageSize recordIndex:(long)recordIndex order:( NSString* _Nullable )order completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMConversationDetails*> * _Nullable data))completionBlock;

- (BOOL)getAllConversations:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMConversationDetails*> * _Nullable data))completionBlock;

- (BOOL)getUser:(nonnull NSString*)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMUser * _Nullable data))completionBlock;

- (void)requestToServer:(nonnull NSDictionary*)dict url:(nonnull NSURL*)url httpMethod:(nonnull NSString*)httpMethod
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock;

@end
