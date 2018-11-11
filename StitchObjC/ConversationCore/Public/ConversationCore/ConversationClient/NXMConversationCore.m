//
//  NXMConversationCore.m
//  StitchObjC
//
//  Created by Chen Lev on 7/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationCore.h"
#import "NXMLogger.h"
#import "NXMNetworkManager.h"
#import "RTCMediaWrapper.h"
#import "NXMPushParserManager.h"

@interface NXMConversationCore()

@property id<NXMConversationCoreDelegate> delegate;
@property NXMNetworkManager *network;
@property RTCMediaWrapper *rtcMedia;
@property NXMUser* user;
// TODO: the use when network is down but still logged in
@property (readwrite) BOOL isLoggedIn;
@property (readwrite) BOOL isConnected;
@property (readwrite, nonnull, nonatomic) NXMPushParserManager *pushParser;

@end

@implementation NXMConversationCore

- (instancetype _Nullable)init {
    if (self = [super init]) {
        //     NXMConversationClientConfig *config = [NXMConversationClientConfig new];
        self.network = [[NXMNetworkManager alloc] initWithHost:@"https://api.nexmo.com/beta/" andWsHost:@"https://ws.nexmo.com/"];
        [self.network setDelegate:(id<NXMNetworkDelegate>)self];
        
        self.rtcMedia = [[RTCMediaWrapper alloc] init];
        [self.rtcMedia setDelegate:self];
        
        self.pushParser = [NXMPushParserManager sharedInstance];
    }
    
    return self;
}

- (void)loginWithAuthToken:(nonnull NSString *)authToken {
    [self.network loginWithToken:authToken];
}

- (void)logout {
    if (!self.isConnected) {
       [NXMLogger error:@"Tried to logout when not connected to CS"];
    } else if (self.isLoggedIn) {
        // TODO: error handling of logout
        [self.network logout];
    } else {
       [NXMLogger error:@"Tried to logout when not logged in"];
    }
}

- (nullable NXMUser *)getUser {
    return  self.user;
}

// TODO:
- (nullable NSString *)getToken {
    //return  self.;
    return nil;
}

- (void)setDelgate:(nonnull id<NXMConversationCoreDelegate>)delegate {
    self.delegate = delegate;
}

- (void)unregisterEvents {
    
}

- (void)connectionStatusChanged:(BOOL)isConnected {
    self.isConnected = isConnected;
    [self.delegate connectionStatusChanged:isConnected];
}

#pragma mark - Push

- (void)enablePushNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
                                     isSandbox:(BOOL)isSandbox
                                     onSuccess:(NXMCoreSuccessCallback _Nullable)onSuccess
                                       onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMEnablePushRequest *request = [[NXMEnablePushRequest alloc] initWithDeviceToken:deviceToken isSandbox:isSandbox];
    [self.network enablePushNotifications:request onSuccess:onSuccess onError:onError];
}

- (void)disablePushNotificationsWithOnSuccess:(NXMCoreSuccessCallback _Nullable)onSuccess
                                      onError:(NXMCoreErrorCallback _Nullable)onError {
    [self.network disablePushNotificationsWithOnSuccess:onSuccess onError:onError];
}

- (BOOL)isStitchPushWithUserInfo:(nonnull NSDictionary *)userInfo {
    return [self.pushParser isStitchPushWithUserInfo:userInfo];
}

- (void)processStitchPushWithUserInfo:(nonnull NSDictionary *)userInfo onSuccess:(NXMCoreSuccessCallbackWithEvent _Nullable)onSuccess onError:(NXMCoreErrorCallback _Nullable)onError {
    if(![self isStitchPushWithUserInfo:userInfo]) {
        if(onError) {
            onError([NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodePushNotAStitchPush andUserInfo:nil]);
            return;
        }
    }
    
    NXMEvent *parsedEvent = [self.pushParser parseStitchPushEventWithUserInfo:userInfo];
    if(!parsedEvent) {
        if(onError) {
            onError([NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodePushParsingFailed andUserInfo:nil]);
        }
        return;
    }
    
    switch (parsedEvent.type) {
        case NXMEventTypeMember:
            if(((NXMMemberEvent *)parsedEvent).state == NXMMemberStateInvited) {
                [self memberInvited:(NXMMemberEvent *)parsedEvent];
            }
            break;
        case NXMEventTypeText:
            [self textRecieved:(NXMTextEvent *)parsedEvent];
        case NXMEventTypeImage:
            [self imageRecieved:(NXMImageEvent *)parsedEvent];
        default:
            break;
    }
    
    if(onSuccess) {
        onSuccess(parsedEvent);
    }
}

#pragma mark - Conversation Methods

- (void)createConversationWithName:(nonnull NSString *)name
             onSuccess:(NXMCoreSuccessCallbackWithId _Nullable)onSuccess
               onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMCreateConversationRequest *request = [[NXMCreateConversationRequest alloc] initWithDisplayName:name];
    [self.network createConversation:request onSuccess:onSuccess onError:onError];
}

- (void)joinToConversation:(nonnull NSString *)conversationId
  withUserId:(nonnull NSString *)userId
   onSuccess:(NXMCoreSuccessCallbackWithObject _Nullable)onSuccess
     onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMAddUserRequest *request = [[NXMAddUserRequest alloc] initWithConversationId:conversationId andUserID:userId];
    [self.network addUserToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)joinToConversation:(nonnull NSString *)conversationId
withMemberId:(nonnull NSString *)memberId
   onSuccess:(NXMCoreSuccessCallbackWithId _Nullable)onSuccess
     onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMJoinMemberRequest *request = [[NXMJoinMemberRequest alloc] initWithConversationId:conversationId andMemberId:memberId];
    [self.network joinMemberToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)inviteToConversation:(nonnull NSString *)conversationId
    withUserId:(nonnull NSString *)userId
     onSuccess:(NXMCoreSuccessCallbackWithObject _Nullable)onSuccess
       onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMInviteUserRequest *request = [[NXMInviteUserRequest alloc] initWithConversationId:conversationId andUserID:userId];
    [self.network inviteUserToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)inviteToConversation:(nonnull NSString *)conversationId
                  withUserId:(nonnull NSString *)userId
                   withMedia:(nonnull NSString *)mediaEnabled
                   onSuccess:(SuccessCallbackWithObject _Nullable)onSuccess
                     onError:(ErrorCallback _Nullable)onError {
    NXMInviteUserRequest *request = [[NXMInviteUserRequest alloc] initWithConversationId:conversationId andUserID:userId];
    [self.network inviteUserToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)inviteToConversation:(nonnull NSString*)userName
    withPhoneNumber:(nonnull NSString*)phoneNumber
     onSuccess:(NXMCoreSuccessCallbackWithId _Nullable)onSuccess
       onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMInvitePstnKnockingRequest *request = [[NXMInvitePstnKnockingRequest alloc] initWithUserName:userName andPhoneNumber:phoneNumber];
    [self.network invitePstnKnockingToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)inviteToConversation:(nonnull NSString *)conversationId
    withUserId:(nonnull NSString *)userId
withPhoneNumber:(nonnull NSString *)phoneNumber
     onSuccess:(NXMCoreSuccessCallbackWithId _Nullable)onSuccess
       onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMInvitePstnRequest *request = [[NXMInvitePstnRequest alloc] initWithConversationId:conversationId andUserID:userId andPhoneNumber:phoneNumber];
    [self.network invitePstnToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)deleteMember:(nonnull NSString *)memberId
fromConversationWithId:(nonnull NSString *)conversationId
           onSuccess:(NXMCoreSuccessCallbackWithId _Nullable)onSuccess
             onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMRemoveMemberRequest *request = [[NXMRemoveMemberRequest alloc] initWithConversationId:conversationId andMemberId:memberId];
    [self.network removeMemberFromConversation:request onSuccess:onSuccess onError:onError];
}

- (void)getConversationDetails:(nonnull NSString*)conversationId
                     onSuccess:(NXMCoreSuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(NXMCoreErrorCallback _Nullable)onError {
    [self.network getConversationDetails:conversationId onSuccess:onSuccess onError:onError];
}

- (void)getConversationsForUser:(nonnull NSString *)userId
                   onSuccess:(NXMCoreSuccessCallbackWithConversations _Nullable)onSuccess
                     onError:(NXMCoreErrorCallback _Nullable)onError {
    [self.network getConversationsForUser:userId onSuccess:onSuccess onError:onError];
}

- (void)getEventsInConversation:(nonnull NSString *)conversationId
        onSuccess:(NXMCoreSuccessCallbackWithEvents _Nullable)onSuccess
          onError:(NXMCoreErrorCallback _Nullable)onError{
    NXMGetEventsRequest *request = [NXMGetEventsRequest new];
    request.conversationId = conversationId;
    [self.network getEvents:request onSuccess:onSuccess onError:onError];
}

- (void)getEventsInConversation:(nonnull NSString *)conversationId
          startId:(nullable NSNumber *)startId
            endId:(nullable NSNumber *)endId
        onSuccess:(NXMCoreSuccessCallbackWithEvents _Nullable)onSuccess
          onError:(NXMCoreErrorCallback _Nullable)onError{
    NXMGetEventsRequest *request = [NXMGetEventsRequest new];
    request.conversationId = conversationId;
    request.startId = startId;
    request.endId = endId;
    [self.network getEvents:request onSuccess:onSuccess onError:onError];
}



- (void)getConversations:(nonnull NXMGetConversationsRequest *)getConversationsRequest
               onSuccess:(NXMCoreSuccessCallbackWithConversations _Nullable)onSuccess
                 onError:(NXMCoreErrorCallback _Nullable)onError {
    [self.network getConversations:getConversationsRequest onSuccess:onSuccess onError:onError];
}


#pragma mark - Messages Methods

- (void)sendText:(nonnull NSString *)text
  conversationId:(nonnull NSString *)conversationId
    fromMemberId:(nonnull NSString *)fromMemberId
       onSuccess:(NXMCoreSuccessCallbackWithId _Nullable)onSuccess
         onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMSendTextEventRequest *request = [[NXMSendTextEventRequest alloc] initWithText:text conversationId:conversationId memberId:fromMemberId];
    
    [self.network sendTextToConversation:request onSuccess:onSuccess onError:onError];
}

- (void)sendImageWithName:(NSString *)imageName
            image:(nonnull NSData *)image
   conversationId:(nonnull NSString *)conversationId
     fromMemberId:(nonnull NSString *)fromMemberId
        onSuccess:(NXMCoreSuccessCallbackWithId _Nullable)onSuccess
          onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMSendImageRequest *request = [[NXMSendImageRequest alloc] initWithImage:imageName image:image conversationId:conversationId memberId:fromMemberId];
    [self.network sendImage:request onSuccess:onSuccess onError:onError];
}

- (void)deleteEvent:(NSInteger)eventId
     conversationId:(nonnull NSString *)conversationId
       fromMemberId:(nonnull NSString *)memberId
          onSuccess:(NXMCoreSuccessCallback _Nullable)onSuccess
            onError:(NXMCoreErrorCallback _Nullable)onError {
    NXMDeleteEventRequest *request = [[NXMDeleteEventRequest alloc] initWithEventId:eventId conversationId:conversationId memberId:memberId];
    [self.network deleteEventFromConversation:request onSuccess:onSuccess onError:onError];
}

- (void)markAsSeen:(NSInteger)messageId
    conversationId:(nonnull NSString *)conversationId
  fromMemberWithId:(nonnull NSString *)memberId
         onSuccess:(NXMCoreSuccessCallback _Nullable)onSuccess
           onError:(NXMCoreErrorCallback _Nullable)onError {
    [self.network seenTextEvent:conversationId memberId:memberId eventId:messageId];
}

- (void)markAsDelivered:(NSInteger)messageId
         conversationId:(nonnull NSString *)conversationId
       fromMemberWithId:(nonnull NSString *)memberId
              onSuccess:(NXMCoreSuccessCallback _Nullable)onSuccess
                onError:(NXMCoreErrorCallback _Nullable)onError {
    [self.network deliverTextEvent:conversationId memberId:memberId eventId:messageId];
}

- (void)startTyping:(nonnull NSString *)conversationId
           memberId:(nonnull NSString *)memberId
          onSuccess:(NXMCoreSuccessCallback _Nullable)onSuccess
            onError:(NXMCoreErrorCallback _Nullable)onError {
    [self.network textTypingOn:conversationId memberId:memberId];
}

- (void)stopTyping:(nonnull NSString *)conversationId
          memberId:(nonnull NSString *)memberId
         onSuccess:(NXMCoreSuccessCallback _Nullable)onSuccess
           onError:(NXMCoreErrorCallback _Nullable)onError {
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

- (NXMStitchErrorCode)sendDTMFWithDigits:(nonnull NSString*)digits
                      andConversationId:(nonnull NSString*)conversationId
                            andMemberId:(nonnull NSString*)memberId
                            andDuration:(int) duration
                                 andGap:(int) gap{
    return [self.rtcMedia sendDTMFWithDigits:digits andConversationId:conversationId andMemberId:memberId andDuration:duration andGap:gap];
}

- (void)suspendMedia:(NXMMediaType)mediaType
            ofMember:(NSString *)memberId
      inConversation:(nonnull NSString *)conversationId
          fromMember:(NSString *)fromMemberId
           onSuccess:(NXMCoreSuccessCallback _Nullable)onSuccess
             onError:(NXMCoreErrorCallback _Nullable)onError {
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
          onSuccess:(NXMCoreSuccessCallback _Nullable)onSuccess
            onError:(NXMCoreErrorCallback _Nullable)onError {
    if(![self isSupportedMediaType:mediaType]) {
        onError([NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeMediaNotSupported andUserInfo:nil]);
    }
    NXMSuspendResumeMediaRequest *mediaRequest = [[NXMSuspendResumeMediaRequest alloc] initWithConversationId:conversationId fromMemberId:fromMemberId toMemberId:memberId rtcId:nil mediaType:mediaType];
    [self.network resumeMediaWithMediaRequest:mediaRequest onSuccess:onSuccess onError:onError];
}

#pragma mark - NXMNetworkDelegate
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error {
    self.user = user;
    self.isLoggedIn = isLoggedIn;
    [self.delegate loginStatusChanged:user loginStatus:isLoggedIn withError:error];
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

- (void)textDelivered:(nonnull NXMMessageStatusEvent *)statusEvent{
    [self.delegate textDelivered:statusEvent];
    
}
- (void)textSeen:(nonnull NXMMessageStatusEvent *)statusEvent{
    [self.delegate textSeen:statusEvent];
    
}

- (void)imageRecieved:(nonnull NXMImageEvent *)imageEvent {
    [self.delegate imageRecieved:imageEvent];
}

- (void)imageDelivered:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.delegate imageDelivered:statusEvent];
}


- (void)imageSeen:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.delegate imageSeen:statusEvent];
}

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textTypingEvent {
    [self.delegate textTypingOn:textTypingEvent];
}

- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textTypingEvent {
    [self.delegate textTypingOff:textTypingEvent];
}

- (void)messageDeleted:(nonnull NXMMessageStatusEvent *)messageEvent {
    [self.delegate messageDeleted:messageEvent];
}

- (void)mediaEvent:(nonnull NXMMediaEvent *)mediaEvent {
    [self.delegate informOnMedia:mediaEvent];
}

- (void)mediaActionEvent:(nonnull NXMMediaActionEvent *)mediaActionEvent {
    [self.delegate actionOnMedia:mediaActionEvent];
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
      onSuccess:(NXMCoreSuccessCallbackWithId)onSuccess
        onError:(NXMCoreErrorCallback)onError {
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
