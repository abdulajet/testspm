//
//  NXMConversationClient.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/26/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NexmoConversationObjC.h"
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

- (void)addUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    [self.router addUserToConversation:conversationId userId:userId completionBlock:completionBlock];
}

- (void)inviteUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    [self.router inviteUserToConversation:conversationId userId:userId completionBlock:completionBlock];
}

- (void)joinMemberToConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    [self.router joinMemberToConversation:conversationId memberId:memberId completionBlock:completionBlock];
}

- (void)removeMemberFromConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    [self.router removeMemberFromConversation:conversationId memberId:memberId completionBlock:completionBlock];
}


- (void)sendText:(nonnull NSString *)text conversationId:(nonnull NSString *)conversationId fromMemberId:(nonnull NSString *)fromMemberId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error,NSDictionary * _Nullable data))completionBlock {
    [self.router sendTextToConversation:conversationId memberId:fromMemberId textToSend:text completionBlock:completionBlock];
//    [self.socketClient sendText:text conversationId:conversationId fromMemberId:fromMemberId completionBlock:^(NSError * _Nullable error, NXMSocketResponse * _Nullable response) {
//        // TODO:
//    }];
}


- (void)deleteText:(nonnull NSString *)conversationId
      fromMemberId:(nonnull NSString *)fromMemberId
           eventId:(nonnull NSString *)eventId
   completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock{
    [self.router deleteTextFromConversation:conversationId memberId:fromMemberId eventId:eventId completionBlock:completionBlock];
}
- (nullable NXMConversationDetails *)getConversationWithCID:(nonnull NSString *)cid {
    return  nil;
}

- (void)getConversation:(nonnull NSString*)conversationId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMConversationDetails * _Nullable data))completionBlock{
    [self.router getConversation:conversationId completionBlock:completionBlock];
}


-(void)getNumOfConversations:(void (^_Nullable)(NSError * _Nullable error, long * _Nullable data)) completionBlock{
    [self.router getNumOfConversations:completionBlock];
}

- (void)getAllConversations:(void (^_Nullable)(NSError * _Nullable, NSArray<NXMConversationDetails *> * _Nullable))completionBlock{
    [self.router getAllConversations:completionBlock];
}

- (void)getConversationsPaging:( NSString* _Nullable )name dateStart:( NSString* _Nullable )dateStart  dateEnd:( NSString* _Nullable )dateEnd pageSize:(long)pageSize recordIndex:(long)recordIndex order:( NSString* _Nullable )order completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMConversationDetails*> * _Nullable data))completionBlock{
    [self.router getConversationsPaging:name dateStart:dateStart dateEnd:dateEnd pageSize:pageSize recordIndex:recordIndex order:order completionBlock:completionBlock];
}


- (void)getUser:(nonnull NSString*)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMUser * _Nullable data))completionBlock{
    [self.router getUser:userId completionBlock:completionBlock];
}
- (nullable NSArray<NXMConversationDetails *> *)getConversationList {
    return  nil;
}

- (void)enableAudio:(nonnull NSString*)conversationId {
    
}

- (void)disableAudio:(nonnull NSString*)conversationId {
    
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

