//
//  NXMConversationCore.m
//  StitchObjC
//
//  Created by Chen Lev on 7/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationCore.h"

#import "NXMNetworkManager.h"
#import "RTCMediaWrapper.h"


@interface NXMConversationCore()

@property id<NXMConversationCoreDelegate> delegate;
//@property NXMSocketClient *socketClient;
//@property NXMRouter *router;
@property NXMNetworkManager *network;
@property NXMUser *user;
@property RTCMediaWrapper *rtcMedia;

@end

@implementation NXMConversationCore

- (instancetype _Nullable)init {
    if (self = [super init]) {
        //     NXMConversationClientConfig *config = [NXMConversationClientConfig new];
        self.network = [[NXMNetworkManager alloc] initWitHost:@"https://api.nexmo.com/beta/" andWsHost:@"https://ws.nexmo.com/"];
        [self.network setDelegate:(id<NXMNetworkDelegate>)self];
        
        self.rtcMedia = [[RTCMediaWrapper alloc] init];
        [self.rtcMedia setDelegate:self];
    }
    
    return self;
}
//- (instancetype _Nullable)initWithConfig:(nonnull NXMConversationClientConfig *)config {
//    if (self = [super init]) {
//        self.network = [[NXMNetworkManager alloc] initWitHost:[config getHttpHost] andWsHost:[config getWSHost]];
//        [self.network setDelegate:(id<NXMNetworkDelegate>)self];
//
//        // TODO: rtcMedia
//    }
//
//    return self;
//}



- (void)loginWithAuthToken:(nonnull NSString *)authToken
                 onSuccess:(SuccessCallbackWithObject _Nullable)onSuccess
                   onError:(ErrorCallback _Nullable)onError {
    [self.network loginWithToken:authToken onSuccess:onSuccess onError:onError];
}

- (void)logout:(void (^_Nullable)(NSError * _Nullable error))responseBlock {
    [self.network logout];
}

- (void)enablePushNotifications:(nonnull NSData *)deviceToken
                      onSuccess:(SuccessCallback _Nullable)onSuccess
                        onError:(ErrorCallback _Nullable)onError {
    NXMEnablePushRequest *request = [[NXMEnablePushRequest alloc] initWithDeviceToken:deviceToken];
    [self.network enablePushNotifications:request onSuccess:onSuccess onError:onError];
}


- (nonnull NXMUser *)getUser {
    return  self.user;
}

// TODO:
- (nonnull NSString *)getToken {
    //return  self.;
    return nil;
}

- (BOOL)isLoggedIn {
    return NO;
} // TODO: the use already login but the network is down?

- (void)setDelgate:(nonnull id<NXMConversationCoreDelegate>)delegate {
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
- (void)invite:(nonnull NSString*)userName
    withPhoneNumber:(nonnull NSString*)phoneNumber
     onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
       onError:(ErrorCallback _Nullable)onError {
    NXMInvitePstnKnockingRequest *request = [[NXMInvitePstnKnockingRequest alloc] initWithUserName:userName andPhoneNumber:phoneNumber];
    [self.network invitePstnKnockingToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)invite:(nonnull NSString *)conversationId
    withUserId:(nonnull NSString *)userId
withPhoneNumber:(nonnull NSString *)phoneNumber
     onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
       onError:(ErrorCallback _Nullable)onError {
    NXMInvitePstnRequest *request = [[NXMInvitePstnRequest alloc] initWithConversationId:conversationId andUserID:userId andPhoneNumber:phoneNumber];
    [self.network invitePstnToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)deleteMember:(nonnull NSString *)memberId
fromConversationWithId:(nonnull NSString *)conversationId
           onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
             onError:(ErrorCallback _Nullable)onError {
    NXMRemoveMemberRequest *request = [[NXMRemoveMemberRequest alloc] initWithConversationId:conversationId andMemberId:memberId];
    [self.network removeMemberFromConversation:request onSuccess:onSuccess onError:onError];
}

- (void)getConversationDetails:(nonnull NSString*)conversationId
                     onSuccess:(SuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(ErrorCallback _Nullable)onError {
    [self.network getConversationDetails:conversationId onSuccess:onSuccess onError:onError];
}

- (void)getUserConversations:(nonnull NSString *)userId
                   onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                     onError:(ErrorCallback _Nullable)onError {
    [self.network getUserConversations:userId onSuccess:onSuccess onError:onError];
}

- (void)getEvents:(nonnull NSString *)conversationId
        onSuccess:(SuccessCallbackWithEvents _Nullable)onSuccess
          onError:(ErrorCallback _Nullable)onError{
    NXMGetEventsRequest *request = [NXMGetEventsRequest new];
    request.conversationId = conversationId;
    [self.network getEvents:request onSuccess:onSuccess onError:onError];
}

- (void)getEvents:(nonnull NSString *)conversationId
          startId:(nullable NSNumber *)startId
            endId:(nullable NSNumber *)endId
        onSuccess:(SuccessCallbackWithEvents _Nullable)onSuccess
          onError:(ErrorCallback _Nullable)onError{
    NXMGetEventsRequest *request = [NXMGetEventsRequest new];
    request.conversationId = conversationId;
    request.startId = startId;
    request.endId = endId;
    [self.network getEvents:request onSuccess:onSuccess onError:onError];
}



- (void)getConversations:(nonnull NXMGetConversationsRequest *)getConversationsRequest
               onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                 onError:(ErrorCallback _Nullable)onError {
    [self.network getConversations:getConversationsRequest onSuccess:onSuccess onError:onError];
}

- (void)getConversationEvents:(nonnull NSString*)conversationId
                  startOffset:(NSUInteger)startOffset
                    endOffset:(NSUInteger)endOffset
                    onSuccess:(SuccessCallbackWithObjects _Nullable)onSuccess
                      onError:(ErrorCallback _Nullable)onError {
    
}


#pragma mark - Messages Methods

- (void)sendText:(nonnull NSString *)text
  conversationId:(nonnull NSString *)conversationId
    fromMemberId:(nonnull NSString *)fromMemberId
       onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
         onError:(ErrorCallback _Nullable)onError {
    NXMSendTextEventRequest *request = [[NXMSendTextEventRequest alloc] initWithText:text conversationId:conversationId memberId:fromMemberId];
    
    [self.network sendTextToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)sendImage:(NSString *)imageName
            image:(nonnull NSData *)image
   conversationId:(nonnull NSString *)conversationId
     fromMemberId:(nonnull NSString *)fromMemberId
        onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
          onError:(ErrorCallback _Nullable)onError {
    NXMSendImageRequest *request = [[NXMSendImageRequest alloc] initWithImage:imageName image:image conversationId:conversationId memberId:fromMemberId];
    [self.network sendImage:request onSuccess:onSuccess onError:onError];
}

- (void)deleteEvent:(NSInteger)eventId
     conversationId:(nonnull NSString *)conversationId
       fromMemberId:(nonnull NSString *)memberId
          onSuccess:(SuccessCallback _Nullable)onSuccess
            onError:(ErrorCallback _Nullable)onError {
    NXMDeleteEventRequest *request = [[NXMDeleteEventRequest alloc] initWithEventId:eventId conversationId:conversationId memberId:memberId];
    [self.network deleteEventFromConversation:request onSuccess:onSuccess onError:onError];
}

- (void)markAsSeen:(NSInteger)messageId
    conversationId:(nonnull NSString *)conversationId
  fromMemberWithId:(nonnull NSString *)memberId
         onSuccess:(SuccessCallback _Nullable)onSuccess
           onError:(ErrorCallback _Nullable)onError {
    [self.network seenTextEvent:conversationId memberId:memberId eventId:messageId];
}

- (void)markAsDelivered:(NSInteger)messageId
         conversationId:(nonnull NSString *)conversationId
       fromMemberWithId:(nonnull NSString *)memberId
              onSuccess:(SuccessCallback _Nullable)onSuccess
                onError:(ErrorCallback _Nullable)onError {
    [self.network deliverTextEvent:conversationId memberId:memberId eventId:messageId];
}

- (void)startTyping:(nonnull NSString *)conversationId
           memberId:(nonnull NSString *)memberId
          onSuccess:(SuccessCallback _Nullable)onSuccess
            onError:(ErrorCallback _Nullable)onError {
    [self.network textTypingOn:conversationId memberId:memberId];
}

- (void)stopTyping:(nonnull NSString *)conversationId
          memberId:(nonnull NSString *)memberId
         onSuccess:(SuccessCallback _Nullable)onSuccess
           onError:(ErrorCallback _Nullable)onError {
    [self.network textTypingOff:conversationId memberId:memberId];
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
    
    [self.delegate connectedWithUser:user];
}

- (void)memberJoined:(nonnull NXMMemberEvent *)member {
    [self.delegate memberJoined:member];
}

- (void)memberRemoved:(nonnull NXMMemberEvent *)member {
    [self.delegate memberRemoved:member];
}

- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent {
    [self.delegate memberInvited:memberEvent];
}

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent {
    [self.delegate textRecieved:textEvent];
}

- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent {
    [self.delegate textDeleted:textEvent];
}

- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent{
    [self.delegate textDelivered:textEvent];
    
}
- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent{
    [self.delegate textSeen:textEvent];
    
}

- (void)imageRecieved:(nonnull NXMImageEvent *)imageEvent {
    [self.delegate imageRecieved:imageEvent];
}

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent {
    [self.delegate textTypingOn:textEvent];
}

- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent {
    [self.delegate textTypingOff:textEvent];
}


- (void)mediaEvent:(nonnull NXMMediaEvent *)mediaEvent {
    [self.delegate mediaChanged:mediaEvent];
}

- (void)mediaAnswerEvent:(nonnull NXMMediaAnswerEvent *)mediaEvent {
    [self.rtcMedia answerWithMediaId:mediaEvent.rtcId convId:mediaEvent.conversationId andSDP:mediaEvent.sdp];
}

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent{
    [self.delegate sipRinging:sipEvent];
}

- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent{
    [self.delegate sipAnswered:sipEvent];
}
- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent{
    [self.delegate sipHangup:sipEvent];
}
- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent{
    [self.delegate sipStatus:sipEvent];
}

#pragma mark - RTCMediaWrapper

- (void)onMediaStatusChangedWithConversationId:(NSString *)conversationId andStatus:(NSString *)status {
    // TODO:
}

- (void)sendSDP:(NSString *)sdp
   andMediaInfo:(MRTCMediaInfo *)mediaInfo
      onSuccess:(SuccessCallbackWithId)onSuccess
        onError:(ErrorCallback)onError {
    [self.network enableMedia:mediaInfo._conversationId memberId:mediaInfo._memberId sdp:sdp mediaType:@"" onSuccess:onSuccess onError:onError];
}

- (void)terminateRtc:(MRTCMediaInfo *)mediaInfo rtcId:(NSString *)rtcId  completionHandler:(void (^)(NSError *))completionHandler {
    [self.network disableMedia:mediaInfo._conversationId rtcId:rtcId memberId:mediaInfo._memberId onSuccess:^{
        completionHandler(nil);
    } onError:^(NSError * _Nullable error) {
        completionHandler(error);
    }];
}

@end
