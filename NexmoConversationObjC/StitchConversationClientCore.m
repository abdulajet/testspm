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

- (BOOL)newConversationWithConversationName:(nonnull NSString *)conversationName responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable conversation))responseBlock {
    return [self.router createConversationWithName:conversationName responseBlock:responseBlock];
 }

- (BOOL)addUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    return [self.router addUserToConversation:conversationId userId:userId completionBlock:completionBlock];
}

- (BOOL)inviteUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    return [self.router inviteUserToConversation:conversationId userId:userId completionBlock:completionBlock];
}

- (BOOL)joinMemberToConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    return [self.router joinMemberToConversation:conversationId memberId:memberId completionBlock:completionBlock];
}

- (BOOL)removeMemberFromConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock {
    return [self.router removeMemberFromConversation:conversationId memberId:memberId completionBlock:completionBlock];
}


- (BOOL)sendText:(nonnull NSString *)text conversationId:(nonnull NSString *)conversationId fromMemberId:(nonnull NSString *)fromMemberId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error,NSDictionary * _Nullable data))completionBlock {
    return [self.router sendTextToConversation:conversationId memberId:fromMemberId textToSend:text completionBlock:completionBlock];
}


- (BOOL)deleteText:(nonnull NSString *)conversationId
      fromMemberId:(nonnull NSString *)fromMemberId
           eventId:(nonnull NSString *)eventId
   completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock{
    return [self.router deleteTextFromConversation:conversationId memberId:fromMemberId eventId:eventId completionBlock:completionBlock];
}
- (BOOL)getConversation:(nonnull NSString*)conversationId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMConversationDetails * _Nullable data))completionBlock{
    return [self.router getConversation:conversationId completionBlock:completionBlock];
}


-(BOOL)getNumOfConversations:(void (^_Nullable)(NSError * _Nullable error, long * _Nullable data)) completionBlock{
    return [self.router getNumOfConversations:completionBlock];
}

- (BOOL)getAllConversations:(void (^_Nullable)(NSError * _Nullable, NSArray<NXMConversationDetails *> * _Nullable))completionBlock{
    return [self.router getAllConversations:completionBlock];
}

- (BOOL)getConversationsPaging:( NSString* _Nullable )name dateStart:( NSString* _Nullable )dateStart  dateEnd:( NSString* _Nullable )dateEnd pageSize:(long)pageSize recordIndex:(long)recordIndex order:( NSString* _Nullable )order completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMConversationDetails*> * _Nullable data))completionBlock{
    return [self.router getConversationsPaging:name dateStart:dateStart dateEnd:dateEnd pageSize:pageSize recordIndex:recordIndex order:order completionBlock:completionBlock];
}


- (BOOL)getUser:(nonnull NSString*)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMUser * _Nullable data))completionBlock{
    return [self.router getUser:userId completionBlock:completionBlock];
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

