//
//  NXMConversationClient.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/26/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "StitchConversationClientCore.h"
#import "NXMSocketClient.h"
#import "NXMRouter.h"

@interface StitchConversationClientCore()

@property id<NXMConversationClientDelegate> delegate;
@property NXMSocketClient *socketClient;
@property NXMRouter *router;
@property NXMUser *user;

@end

@implementation StitchConversationClientCore

- (instancetype _Nullable)initWithConfig:(nonnull NXMConversationClientConfig *)config {
    if (self = [super init]) {
        NSString *host = [config getWSHost];
        self.socketClient = [[NXMSocketClient alloc] initWitHost:host];
        [self.socketClient setDelegate:(id<NXMSocketClientDelegate>)self];
        
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

- (void)createConversation:(nonnull NXMCreateConversationRequest *)createConversationRequest
        responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable conversationID))responseBlock {
    [self.router createConversation:createConversationRequest responseBlock:responseBlock];
 }
- (void)addUserToConversation:(NXMAddUserRequest *)addUserRequest completionBlock:(void (^)(NSError * _Nullable, NSDictionary * _Nullable))completionBlock
{
    [self.router addUserToConversation:addUserRequest completionBlock:completionBlock];
}

- (void)inviteUserToConversation:(nonnull NXMInviteUserRequest *)inviteUserRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    [self.router inviteUserToConversation:inviteUserRequest completionBlock:completionBlock];
}

- (void)joinMemberToConversation:(nonnull NXMJoinMemberRequest *)joinMemberRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    [self.router joinMemberToConversation:joinMemberRequest completionBlock:completionBlock];
}

- (void)removeMemberFromConversation:(nonnull NXMRemoveMemberRequest *)removeMemberRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    [self.router removeMemberFromConversation:removeMemberRequest completionBlock:completionBlock];
}


- (void)sendText:(nonnull NXMSendTextEventRequest *)sendTextEventRequest
        completionBlock:(void (^_Nullable)(NSError * _Nullable error,NSDictionary * _Nullable data))completionBlock {
    return [self.router sendTextToConversation:sendTextEventRequest completionBlock:completionBlock];
}


- (void)deleteText:(nonnull NXMDeleteEventRequest *)deleteEventRequest
   completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock{
    [self.router deleteTextFromConversation:deleteEventRequest completionBlock:completionBlock];
}
- (void)getConversationDetails:(nonnull NSString*)conversationId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMConversationDetails * _Nullable data))completionBlock{
    [self.router getConversationDetails:conversationId completionBlock:completionBlock];
}


- (void)getConversations:( NXMGetConversationsRequest* _Nullable )getConversationsRequest
         completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMConversationDetails*> * _Nullable data))completionBlock{
    [self.router getConversations:getConversationsRequest completionBlock:completionBlock];
}


- (void)getUser:(nonnull NSString*)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMUser * _Nullable data))completionBlock{
    [self.router getUser:userId completionBlock:completionBlock];
}
- (nullable NSArray<NXMConversationDetails *> *)getConversationList {
    return  nil;
}

- (BOOL)enableAudio:(nonnull NSString*)conversationId {
    
    return YES;
}

- (BOOL)disableAudio:(nonnull NSString*)conversationId {
    
    return YES;
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


- (void)connectionStatusChanged:(BOOL)isOpen {
    
}


- (void)seenTextEvent:(nonnull NSString *)conversationId
             memberId:(nonnull NSString *)memberId
              eventId:(nonnull NSString *)eventId
{
    [self.socketClient seenTextEvent:conversationId memberId:memberId eventId:eventId];
}


- (void)deliverTextEvent:(nonnull NSString *)conversationId
                memberId:(nonnull NSString *)memberId
                 eventId:(nonnull NSString *)eventId
{
    [self.socketClient deliverTextEvent:conversationId memberId:memberId eventId:eventId];
}

- (void)textTypingOnEvent:(nonnull NSString *)conversationId
            memberId:(nonnull NSString *)memberId
{
    [self.socketClient textTypingOn:conversationId memberId:memberId];
}

- (void)textTypingOffEvent:(nonnull NSString *)conversationId
             memberId:(nonnull NSString *)memberId
{
    [self.socketClient textTypingOff:conversationId memberId:memberId];
}


#pragma mark - NXMSocketCllientDelegate

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

- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent{
    [self.delegate textDeleted:textEvent];
}

- (void)messageReceived:(nonnull NXMTextEvent *)message{
    [self.delegate messageReceived:message];
}
- (void)messageSent:(nonnull NXMTextEvent *)message{
    [self.delegate messageSent:message];
}

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent{
    [self.delegate textTypingOn:textEvent];
}
- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent{
    [self.delegate textTypingOff:textEvent];
}

- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent{
    [self.delegate textDelivered:textEvent];
    
}
- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent{
    [self.delegate textSeen:textEvent];
    
}
@end

