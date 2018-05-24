//
//  NXMConversationClient.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/26/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "StitchConversationClientCore.h"
#import "NXMNetworkManager.h"

#import "RTCMediaWrapper.h"


@interface StitchConversationClientCore()

@property id<NXMConversationClientDelegate> delegate;
//@property NXMSocketClient *socketClient;
//@property NXMRouter *router;
@property NXMNetworkManager *network;
@property NXMUser *user;
@property RTCMediaWrapper *rtcMedia;

@end

@implementation StitchConversationClientCore

- (instancetype _Nullable)initWithConfig:(nonnull NXMConversationClientConfig *)config {
    if (self = [super init]) {
        NSString *host = [config getWSHost];
//        self.socketClient = [[NXMSocketClient alloc] initWitHost:host];
//        [self.socketClient setDelegate:(id<NXMSocketClientDelegate>)self];
//
//        self.router = [[NXMRouter alloc] initWitHost:[config getHttpHost]];

        self.network = [[NXMNetworkManager alloc] initWitHost:[config getHttpHost] andWsHost:host];
        [self.network setDelegate:(id<NXMNetworkDelegate>)self];
        // TODO: rtcMedia
    }
    
    return self;
}

- (void)enablePushNotifications:(BOOL)enable responseBlock:(void (^_Nullable)(NSError * _Nullable error))responseBlock {
    
}

- (void)loginWithAuthToken:(nonnull NSString *)authToken {
    [self.network loginWithToken:authToken];
}

- (void)logout:(void (^_Nullable)(NSError * _Nullable error))responseBlock {
    [self.network logout];
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

#pragma mark - Conversation Methods

- (void)createWithName:(nonnull NSString *)name
             onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
               onError:(ErrorCallback _Nullable)onError {
    NXMCreateConversationRequest *request = [[NXMCreateConversationRequest alloc] initWithDisplayName:name];
    [self.network createConversation:request onSuccess:onSuccess onError:onError];
}

- (void)join:(nonnull NSString *)conversationId
  withUserId:(nonnull NSString *)userId
   onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
     onError:(ErrorCallback _Nullable)onError {
    NXMAddUserRequest *request = [[NXMAddUserRequest alloc] initWithConversationId:conversationId andUserID:userId];
    [self.network addUserToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)join:(nonnull NSString *)conversationId
withMemberId:(nonnull NSString *)memberId
   onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
     onError:(ErrorCallback _Nullable)onError {
    NXMJoinMemberRequest *request = [[NXMJoinMemberRequest alloc] initWithConversationId:conversationId andMemberId:memberId];
    [self.network joinMemberToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)invite:(nonnull NSString *)conversationId
    withUserId:(nonnull NSString *)userId
     onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
       onError:(ErrorCallback _Nullable)onError {
    NXMInviteUserRequest *request = [[NXMInviteUserRequest alloc] initWithConversationId:conversationId andUserID:userId];
    [self.network inviteUserToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)deleteMember:(nonnull NSString *)memberId
fromConversationWithId:(nonnull NSString *)conversationId
           onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
             onError:(ErrorCallback _Nullable)onError {
    NXMRemoveMemberRequest *request = [[NXMRemoveMemberRequest alloc] initWithConversationId:conversationId andMemberId:memberId];
    [self.network removeMemberFromConversation:request onSuccess:onSuccess onError:onError];
}

- (void)getConversationDetails:(nonnull NSString*)conversationId
                     onSuccess:(SuccessCallbackWithObject _Nullable)onSuccess
                       onError:(ErrorCallback _Nullable)onError {
    [self.network getConversationDetails:conversationId onSuccess:onSuccess onError:onError];
}

- (void)getConversations:(NXMGetConversationsRequest* _Nullable )getConversationsRequest
               onSuccess:(SuccessCallbackWithObjects _Nullable)onSuccess
                 onError:(ErrorCallback _Nullable)onError {
    
}

- (void)getConversationEvents:(nonnull NSString*)conversationId
                  startOffset:(NSUInteger)startOffset
                    endOffset:(NSUInteger)endOffset
                    onSuccess:(SuccessCallbackWithObjects _Nullable)onSuccess
                      onError:(ErrorCallback _Nullable)onError {
    
}

#pragma mark - Media Methods

- (NXMStitchErrorCode)enableMedia:(nonnull NSString *)conversationId
                         memberId:(nonnull NSString *)memberId {
    [self.rtcMedia enableMediaWithMediaID:conversationId memberId:memberId andWithAudio:NXMMediaStreamTypeSendReceive andWithVideo:NXMMediaStreamTypeNone];
    
    return NXMStitchErrorCodeNone;
}

- (NXMStitchErrorCode)disableMedia:(nonnull NSString *)conversationId {
    [self.rtcMedia disableMedia:conversationId];
    
    return NXMStitchErrorCodeNone;
}


#pragma mark - NXMSocketCllientDelegate

- (void)userStatusChanged:(NXMUser *)user sessionId:(NSString*)sessionId {
    self.user = user;
    
  //  [self.router setSessionId:sessionId];
    
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
    [self.delegate textRecieved:message];
}
- (void)messageSent:(nonnull NXMTextEvent *)message{
    [self.delegate textSent:message];
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

- (void)mediaEvent:(nonnull NXMMediaEvent *)mediaEvent {
    
}
- (void)mediaAnswerEvent:(nonnull NXMMediaAnswerEvent *)mediaEvent {
    [self.rtcMedia answerWithMediaId:mediaEvent.rtcId andSDP:mediaEvent.sdp];
}

#pragma mark -

- (void)onMediaStatusChangedWithConversationId:(NSString *)conversationId andStatus:(NSString *)status {
    // TODO:
}

- (void)sendSDP:(NSString *)sdp andMediaInfo:(MRTCMediaInfo *)mediaInfo andCompletionHandler:(void (^)(NSError *))completionHandler {
    [self.network enableMedia:mediaInfo._conversationId memberId:mediaInfo._memberId sdp:sdp mediaType:@"" onSuccess:^(NSString *value) {
        completionHandler(nil);
    } onError:^(NSError *error) {
        completionHandler(error);
    }];
}

//- (void)mediaAnswerEvent:(nonnull NXMMediaAnswerEvent *)mediaEvent {
//   // [self.rtcMedia answerWithMediaId:mediaEvent.rtcId andSDP:mediaEvent.sdp];
//}

@end


