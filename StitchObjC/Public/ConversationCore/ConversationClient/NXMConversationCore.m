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

- (void)createConversationWithName:(nonnull NSString *)name
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

- (NXMStitchErrorCode)suspendMyMedia:(NXMMediaType)mediaType
                    inConversation:(nonnull NSString *)conversationId{
    if(![self isSupportedMediaType:mediaType]) {
        return NXMStitchErrorCodeMediaNotSupported;
    }
    return [self.rtcMedia suspendMediaWithMediaId:conversationId andMediaType:mediaType];
}

- (NXMStitchErrorCode)resumeMyMedia:(NXMMediaType)mediaType
                    inConversation:(nonnull NSString *)conversationId{
    if(![self isSupportedMediaType:mediaType]) {
        return NXMStitchErrorCodeMediaNotSupported;
    }
    return [self.rtcMedia resumeMediaWithMediaId:conversationId andMediaType:mediaType];
}

- (void)suspendMedia:(NXMMediaType)mediaType
            ofMember:(NSString *)memberId
      inConversation:(nonnull NSString *)conversationId
          fromMember:(NSString *)fromMemberId
           onSuccess:(SuccessCallback _Nullable)onSuccess
             onError:(ErrorCallback _Nullable)onError {
    if(![self isSupportedMediaType:mediaType]) {
        onError([NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeMediaNotSupported andUserInfo:nil]);
    }
    NXMSuspendResumeMediaRequest *mediaRequest = [[NXMSuspendResumeMediaRequest alloc] initWithConversationId:conversationId fromMemberId:fromMemberId toMemberId:memberId rtcId:nil mediaType:mediaType];
    [self.network suspendMediaWithMediaRequest:mediaRequest onSuccess:onSuccess onError:onError];
}

- (void)resumeMedia:(NXMMediaType)mediaType
           ofMember:(NSString *)memberId
     inConversation:(nonnull NSString *)conversationId
         fromMember:(NSString *)fromMemberId
          onSuccess:(SuccessCallback _Nullable)onSuccess
            onError:(ErrorCallback _Nullable)onError {
    if(![self isSupportedMediaType:mediaType]) {
        onError([NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeMediaNotSupported andUserInfo:nil]);
    }
    NXMSuspendResumeMediaRequest *mediaRequest = [[NXMSuspendResumeMediaRequest alloc] initWithConversationId:conversationId fromMemberId:fromMemberId toMemberId:memberId rtcId:nil mediaType:mediaType];
    [self.network resumeMediaWithMediaRequest:mediaRequest onSuccess:onSuccess onError:onError];
}


#pragma mark - NXMNetworkDelegate

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
    [self.delegate informOnMedia:mediaEvent];
}

- (void)mediaActionEvent:(nonnull NXMMediaActionEvent *)mediaEvent {
    [self.delegate actionOnMedia:mediaEvent];
}

- (void)rtcAnswerEvent:(nonnull NXMRtcAnswerEvent *)rtcEvent {
    [self.rtcMedia answerWithMediaId:rtcEvent.rtcId convId:rtcEvent.conversationId andSDP:rtcEvent.sdp];
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

#pragma mark - RTCMediaWrapperDelegate

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

- (void)didMuteStateChangeWithMediaInfo:(NXMMediaInfo *)mediaInfo andIsMute:(bool)isMute andMediaType:(NXMMediaType)mediaType {
    NXMMediaSuspendEvent *mediaEvent = [NXMMediaSuspendEvent new];
    mediaEvent.fromMemberId = mediaInfo.memberId;
    mediaEvent.toMemberId = mediaInfo.memberId;
    mediaEvent.conversationId = mediaInfo.conversationId;
    mediaEvent.type = NXMEventTypeMediaAction;
    mediaEvent.creationDate = [NSDate date];
    mediaEvent.actionType = NXMMediaActionTypeSuspend;
    mediaEvent.mediaType = mediaType;
    mediaEvent.isSuspended = isMute;

    [self.delegate localActionOnMedia:mediaEvent];
}


- (void)sendMuteStateWithMediaInfo:(NXMMediaInfo *)mediaInfo andIsMute:(bool)isMute andMediaType:(NXMMediaType)mediaType onSuccess:(void (^) (void))onSuccess onError:(void (^) (NSError * _Nullable error))onError {
    
    NXMSuspendResumeMediaRequest *mediaRequest = [[NXMSuspendResumeMediaRequest alloc] initWithConversationId:mediaInfo.conversationId fromMemberId:mediaInfo.memberId toMemberId:mediaInfo.memberId rtcId:mediaInfo.rtcId mediaType:mediaType];
    
    if(isMute) {
        [self.network suspendMediaWithMediaRequest:mediaRequest onSuccess:onSuccess onError:onError];
    }
    else {
        [self.network resumeMediaWithMediaRequest:mediaRequest onSuccess:onSuccess onError:onError];
    }
}

#pragma mark - private
-(bool)isSupportedMediaType:(NXMMediaType)mediaType {
    switch (mediaType) {
        case NXMMediaTypeAudio:
            return true;
        case NXMMediaTypeVideo:
        case NXMMediaTypeNone:
        default:
            return false;
    }
}


@end
