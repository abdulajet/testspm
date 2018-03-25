//
//  NXMConversationClient.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/26/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <NexmoConversationObjC.h>
#import "NXMSocketClient.h"
#import "NXMRouter.h"

@interface NXMConversationClient()

@property id<NXMConversationClientDelegate> delegate;
@property NXMSocketClient *socketClient;
@property NXMRouter *router;
@property NXMUser *user;

@end

@implementation NXMConversationClient

- (instancetype _Nullable)initWithConfig:(nonnull NXMConversationClientConfig *)config {
    if (self = [super init]) {
        NSString *host = [config getWSHost];
        self.socketClient = [[NXMSocketClient alloc] initWitHost:host];
        [self.socketClient setDelegate:self];
        
        self.router = [[NXMRouter alloc] initWitHost:[config getHttpHost]];
    }
    
    return self;
}

- (void)enablePushNotifications:(BOOL)enable responseBlock:(void (^_Nullable)(NSError * _Nullable error))responseBlock {
    
}

- (void)loginWithToken:(nonnull NSString *)token {
    [self.socketClient loginWithToken:token];
    [self.router setToken:token];
}

- (void)logout:(void (^_Nullable)(NSError * _Nullable error))responseBlock {
    
}

- (void)newConversationWithConversationName:(nonnull NSString *)conversationName responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable conversation))responseBlock {
    [self.router createConversationWithName:conversationName responseBlock:responseBlock];
    
}

- (void)addUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock {
    [self.router addUserToConversation:conversationId userId:userId completionBlock:completionBlock];
}

- (void)inviteUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock {
    [self.router inviteUserToConversation:conversationId userId:userId completionBlock:completionBlock];
}

- (void)joinMemberToConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock {
    [self.router joinMemberToConversation:conversationId memberId:memberId completionBlock:completionBlock];
}

- (void)removeMemberFromConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock {
    [self.router removeMemberFromConversation:conversationId memberId:memberId completionBlock:completionBlock];
}


- (void)sendText:(nonnull NSString *)text
  conversationId:(nonnull NSString *)conversationId
    fromMemberId:(nonnull NSString *)fromMemberId
 completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock {
    [self.router sendTextToConversation:conversationId memberId:fromMemberId textToSend:text completionBlock:completionBlock];
//    [self.socketClient sendText:text conversationId:conversationId fromMemberId:fromMemberId completionBlock:^(NSError * _Nullable error, NXMSocketResponse * _Nullable response) {
//        // TODO:
//    }];
}
- (nullable NXMConversationDetails *)getConversationWithCID:(nonnull NSString *)cid {
    return  nil;
}

- (nullable NSArray<NXMConversationDetails *> *)getConversationList {
    return  nil;
}

- (void)enableAudio {
    
}

- (void)disableAudio {
    
}

- (nonnull NXMConnectionStatus *)getConnectionStatus {
    return  nil;
}

- (nonnull NXMUser *)getUser {
    return  self.user;
}

- (nonnull NSString *)getToken {
    //return  self.;
    return nil;
}

- (BOOL)isLoggedIn {
    return NO;
} // TODO: the use already login but the network is down?

- (void)registerEventsWithDelegate:(nonnull id<NXMConversationClientDelegate>)delegate {
    self.delegate = delegate;
}

- (void)unregisterEvents {
    
}

#pragma mark - NXMSocketCllientDelegate

- (void)connectionStatusChanged:(BOOL)isOpen {
    
}

- (void)userStatusChanged:(NXMUser *)user {
    self.user = user;
    
    [self.delegate connectedWithUser:user];
}

- (void)memberJoined:(nonnull NXMMember *)member {
    [self.delegate memberJoined:member];
}

- (void)memberRemoved:(nonnull NXMMember *)member {
    [self.delegate memberRemoved:member];
}

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent{
    [self.delegate textRecieved:textEvent];
    
}

- (void)messageReceived:(nonnull NXMTextEvent *)message{
    [self.delegate messageReceived:message];
}
- (void)messageSent:(nonnull NXMTextEvent *)message{
    [self.delegate messageSent:message];
}

@end

