//
//  NXMSocketClient.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPSocketIO.h"

#import "NXMSocketClient.h"
#import "NXMSocketClientDefine.h"

#import "NXMLogger.h"

#import "NXMErrorsPrivate.h"
#import "NXMCoreEventsPrivate.h"
#import "NXMUserPrivate.h"
#import "NXMLegPrivate.h"

#import "NXMUtils.h"



@interface NXMSocketClient()

@property (weak) id<NXMSocketClientDelegate> delegate;
@property VPSocketIOClient *socket;
@property NSString *token;
@property NXMConnectionStatus status;

@end

@implementation NXMSocketClient

static NSString *const nxmURL = @"https://honey-api.npe.nexmo.io/beta";

#pragma mark - Public
- (instancetype)initWithHost:(NSString *)host {
    if (self = [super init]) {
        
        VPSocketLogger *logger = [VPSocketLogger new];
        
        NSString *urlString = host;
        NSDictionary *connectParams = @{@"EIO":@"3"};
        self.socket = [[VPSocketIOClient alloc] init:[NSURL URLWithString:urlString]
                                          withConfig:@{@"log": @YES,
                                                       @"secure": @YES,
                                                       @"forceNew":@YES,
                                                       @"path":@"/rtc/",
                                                       @"forceWebsockets":@YES,
                                                       @"selfSigned":@YES,
                                                       @"reconnectWait":@2,
                                                       @"nsp":@"/",
                                                       @"connectParams":connectParams,
                                                       @"logger":logger
                                                       }];
        
        [self subscribeSocketEvent];
    }
    
    return self;
}
#pragma mark login

- (NXMConnectionStatus)connectionStatus {
    return self.status;
}

- (void)loginWithToken:(NSString *)token {
    self.token = token;
    [self connectSocket];
}

- (void)refreshAuthToken:(nonnull NSString *)authToken {
    
    if (self.status != NXMConnectionStatusConnected) {
        [self loginWithToken:authToken];
        return;
    }
    
    self.token = authToken;

    NSDictionary * msg = @{ @"body" : @{
                                    @"token":authToken
                                    }};
    
    [self.socket emit:kNXMSocketEventRefreshToken items:@[msg]];
}

- (void)logout {
    if (self.status == NXMConnectionStatusConnected) {
        [self serverLogout];
    }
}

#pragma mark conversation actions
- (void)seenTextEvent:(nonnull NSString *)conversationId
             memberId:(nonnull NSString *)memberId
              eventId:(NSInteger)eventId
{
    NSDictionary * msg = @{
                           @"cid": conversationId,
                           @"from":memberId,
                           @"body" : @{
                                   @"event_id":[NSNumber numberWithInteger:eventId]
                                   }};
    
    [self.socket emit:kNXMSocketEventTextSeen items:@[msg]];
}


- (void)deliverTextEvent:(nonnull NSString *)conversationId
                memberId:(nonnull NSString *)memberId
                 eventId:(NSInteger)eventId
{
    NSDictionary * msg = @{
                           @"cid": conversationId,
                           @"from":memberId,
                           @"body" : @{
                                   @"event_id":[NSNumber numberWithInteger:eventId]
                                   }};
    
    [self.socket emit:kNXMSocketEventTextDelivered items:@[msg]];
    
}

- (void)textTypingOn:(nonnull NSString *)conversationId
            memberId:(nonnull NSString *)memberId;
{
    
    NSDictionary * msg = @{
                           @"cid": conversationId,
                           @"from":memberId,
                           @"body" : @{
                                   }};
    
    [self.socket emit:kNXMSocketEventTypingOn items:@[msg]];
}

- (void)textTypingOff:(nonnull NSString *)conversationId
             memberId:(nonnull NSString *)memberId
{
    NSDictionary * msg = @{
                           @"cid": conversationId,
                           @"from":memberId,
                           @"body" : @{
                                   }};
    
    [self.socket emit:kNXMSocketEventTypingOff items:@[msg]];
}


#pragma mark - Private
#pragma mark Socket
- (void)connectSocket {
    switch (self.socket.status) {
        case VPSocketIOClientStatusNotConnected:
        case VPSocketIOClientStatusDisconnected:
            self.socket.reconnects = YES;
            [self.socket connect];
            break;
        case VPSocketIOClientStatusConnecting:
        case VPSocketIOClientStatusOpened:
        case VPSocketIOClientStatusConnected:
        default:
            break;
    }
}

- (void)disconnectSocket {
    switch (self.socket.status) {
        case VPSocketIOClientStatusConnected:
        case VPSocketIOClientStatusOpened:
        case VPSocketIOClientStatusConnecting:
            [self.socket disconnect];
            break;
        case VPSocketIOClientStatusNotConnected:
        case VPSocketIOClientStatusDisconnected:
        default:
            break;
    }
}

- (void)socketDidConnect {
    [NXMLogger debug:@"socket connected"];

    //TODO: question - what happens if we try to log in while already logged in to the server for example after a reconnect?
    [self serverLogin];
}

- (void)didSocketDisconnect {
    [self updateConnetionStatus:NXMConnectionStatusDisconnected reason:NXMConnectionStatusReasonTerminated];
}

- (void)socketDidChangeStatus {
    switch (self.socket.status) {
        case VPSocketIOClientStatusConnected:
            [NXMLogger debug:@"socket connected"];
            [self socketDidConnect];
            break;
        case VPSocketIOClientStatusNotConnected:
            [NXMLogger debug:@"socket not connected"];
            [self didSocketDisconnect];
            break;
        case VPSocketIOClientStatusDisconnected:
            [NXMLogger debug:@"socket disconnected"];
            [self didSocketDisconnect];
            break;
        case VPSocketIOClientStatusConnecting: //TODO: support reporting reconnect? or keep it boolean
            [NXMLogger debug:@"socket connecting"];
            [self updateConnetionStatus:NXMConnectionStatusConnecting reason:NXMConnectionStatusReasonUnknown];
            break;
        case VPSocketIOClientStatusOpened:
            [NXMLogger debug:@"socket opened"];
            break;
    }
}

#pragma mark login
- (void)serverLogin {
    NSDictionary * msg = @{@"tid": [[NSUUID UUID] UUIDString],
                           @"body" : @{
                                   @"token": self.token,
                                   @"device_id": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                                   @"device_type": @"iphone",
                                   @"SDK_version": [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey: @"CFBundleShortVersionString"],
                                   @"OS_family": @"iOS"
                                   //TODO: check what the js sdk mean by OS_revision: (typeof navigator !== "undefined") ? navigator.userAgent : (typeof window !== "undefined") ? window.navigator.userAgent : "Generic JS navigator"
                                   }};
    
    [self.socket emit:kNXMSocketEventLogin items:@[msg]];
}

- (void)serverLogout {
    NSDictionary * msg = @{@"tid": [[NSUUID UUID] UUIDString]};
    [self.socket emit:kNXMSocketEventLogout items:@[msg]];
}

- (void)didFailLoginWithError:(NXMErrorCode)error {
    self.token = nil;
    [self disconnectSocket];
    
    NXMConnectionStatusReason reason = NXMConnectionStatusReasonUnknown;
    
    switch (error) {
        case NXMErrorCodeSessionInvalid:
        case NXMErrorCodeMaxOpenedSessions:
            reason = NXMConnectionStatusReasonTerminated;
            break;
        case NXMErrorCodeTokenInvalid:
            reason = NXMConnectionStatusReasonTokenInvalid;
            break;
        case NXMErrorCodeTokenExpired:
            reason = NXMConnectionStatusReasonTokenExpired;
            break;
        default:
            break;
    }
    
    [self updateConnetionStatus:NXMConnectionStatusDisconnected reason:reason];
}

- (void)didServerLoginWithData:(NSArray *)data {
    NSDictionary *response = ((NSDictionary *)data[0])[@"body"];
    NXMUser *user = [[NXMUser alloc] initWithData:response];
    
    NSString * sessionid = response[@"id"];
    [self.delegate userChanged:user withSessionId:sessionid];
    
    [self updateConnetionStatus:NXMConnectionStatusConnected reason:NXMConnectionStatusReasonLogin];
}

- (void)didServerLogout {
    [NXMLogger debug:@"did server logout"];
    self.token = nil;
    
    [self updateConnetionStatus:NXMConnectionStatusDisconnected reason:NXMConnectionStatusReasonLogout];

    [self disconnectSocket];
}

// TODO: thread safe
- (void)updateConnetionStatus:(NXMConnectionStatus)newStatus reason:(NXMConnectionStatusReason)reason {
    if (self.status != newStatus) {
        self.status = newStatus;
        [self.delegate connectionStatusChanged:newStatus reason:reason];
    }
}


#pragma mark subscribe

- (void)subscribeSocketEvent {
    [self subscribeVPSocketEvents];
    [self subscribeGeneralEvents];
    [self subscribeLoginEvents];
    [self subscribeMemberEvents];
    [self subscribeTextEvents];
    [self subscribeRTCEvents];
    [self subscribeSipEvents];
    [self subscribeLegStatusEvents];
}

- (void)subscribeVPSocketEvents {
    __weak NXMSocketClient *weakSelf = self;
    [self.socket on:kSocketEventStatusChange callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [weakSelf socketDidChangeStatus];
    }];

    [self.socket on:kSocketEventError callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger error:@"socket error"];
    }];
}

- (void)subscribeGeneralEvents {
    [self.socket on:kNXMSocketEventBadPermission callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket BadPermission"];
    }];

    [self.socket on:kNXMSocketEventInvalidEvent callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventInvalidEvent"];
    }];
    
    [self.socket on:kNXMSocketEventUserNotFound callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventUserNotFound"];
        //TODO: check if this means anything about login/logout and also regard the invaliduser sessioninternalerror
    }];
}

- (void)subscribeLoginEvents {
    __weak NXMSocketClient *weakSelf = self;

    [self.socket on:kNXMSocketEventLoginSuccess callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"socketLoginSuccess"];
        [weakSelf didServerLoginWithData:data];
    }];
    
    [self.socket on:kNXMSocketEventSessionLogoutSuccess callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"socketLogoutSuccess"];
        [weakSelf didServerLogout];
    }];
    
    [self.socket on:kNXMSocketEventSessionTerminated callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"socketSessionTerminated"];
        [weakSelf didServerLogout];
    }];
    
    [self.socket on:kNXMSocketEventSessionInvalid callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventSessionInvalid"];
        [weakSelf didFailLoginWithError:NXMErrorCodeSessionInvalid];
    }];
    
    [self.socket on:kNXMSocketEventSessionErrorInvalid callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventSessionErrorInvalid"];
        [weakSelf didFailLoginWithError:NXMErrorCodeSessionInvalid];
    }];
    
    [self.socket on:kNXMSocketEventMaxOpenedSessions callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventMaxOpenedSessions"];
        [weakSelf didFailLoginWithError:NXMErrorCodeMaxOpenedSessions];
    }];
    
    [self.socket on:kNXMSocketEventInvalidToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventInvalidToken"];
        [weakSelf didFailLoginWithError:NXMErrorCodeTokenInvalid]; //TODO: check if this might happen without meaning a logout
    }];
    
    [self.socket on:kNXMSocketEventExpiredToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventExpiredToken"];
        [weakSelf didFailLoginWithError:NXMErrorCodeTokenExpired]; //TODO: check if this might happen without meaning a logout
    }];
    
    [self.socket on:kNXMSocketEventRefreshTokenDone callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventRefreshTokenDone"];
        [weakSelf.delegate connectionStatusChanged:NXMConnectionStatusConnected reason:NXMConnectionStatusReasonTokenRefreshed];
    }];
}

- (void)subscribeMemberEvents {
    __weak NXMSocketClient *weakSelf = self;

    [self.socket on:kNXMSocketEventMemberJoined callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventMemberJoined"];
        [weakSelf onMemberJoined:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMemberInvited callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventMemberInvited"];
        [weakSelf onMemberInvited:data emitter:emitter];
    }];
    
    
    [self.socket on:kNXMSocketEventMemberLeft callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventMemberLeft"];
        [weakSelf onMemberLeft:data emitter:emitter];
    }];
}

- (void)subscribeTextEvents {
    __weak NXMSocketClient *weakSelf = self;

    [self.socket on:kNXMSocketEventText callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventText"];
        [weakSelf onTextRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextSuccess callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTextSuccess"];
     //   [weakSelf onTextRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMessageDelete callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTextDelete"];
        [weakSelf onMessageDeleted:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextSeen callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTextSeen"];
        [weakSelf onTextSeen:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextDelivered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTextDelivered"];
        [weakSelf onTextDelivered:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImage callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventImage"];
        [weakSelf onImageRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImageSeen callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventImageSeen"];
        [weakSelf onImageSeen:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImageDelivered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventImageDelivered"];
        [weakSelf onImageDelivered:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTypingOn callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTypingOn"];
        [weakSelf onTextTypingOn:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTypingOff callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTypingOff"];
        [weakSelf onTextTypingOff:data emitter:emitter];
    }];
}

- (void)subscribeRTCEvents {
    __weak NXMSocketClient *weakSelf = self;

    [self.socket on:kNXMSocketEventRtcAnswer callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventRtcAnswer"];
        [weakSelf onRTCAnswer:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMemebrMedia callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventMemebrMedia"];
        [weakSelf onRTCMemberMedia:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventAudioMuteOn callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventAudioMuteOn"];
        [weakSelf onRTCAudioMuteOn:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventAudioMuteOff callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventAudioMuteOff"];
        [weakSelf onRTCAudioMuteOff:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventAudioDtmf callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventAudioDtmf"];
        [weakSelf onAudioDTMF:data emitter:emitter];
    }];
}
- (void)subscribeSipEvents{
    __weak NXMSocketClient *weakSelf = self;

    [self.socket on:kNXMSocketEventSipRinging callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventSipRinging"];
        [weakSelf onSipRinging:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventSipAnswered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventSipAnswered"];
        [weakSelf onSipAnswered:data emitter:emitter];
    }];

    [self.socket on:kNXMSocketEventSipHangup callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventSipHangup"];
        [weakSelf onSipHangup:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventSipStatus callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventSipStatus"];
        [weakSelf onSipStatus:data emitter:emitter];
    }];
}

- (void)subscribeLegStatusEvents{
    __weak NXMSocketClient *weakSelf = self;
    
    [self.socket on:kNXMSocketEventLegStatus callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventSipRinging"];
        [weakSelf onLegStatus:data emitter:emitter];
    }];
}



#pragma mark - Socket Events

#pragma mark members
- (void)onMemberJoined:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [[NXMMemberEvent alloc] initWithConversationId:json[@"cid"]
                                                                      sequenceId:[json[@"id"] integerValue]
                                                                        andState:NXMMemberStateJoined
                                                                         andData:json[@"body"]
                                                                    creationDate:[NXMUtils dateFromISOString:json[@"timestamp"]]
                                                                        memberId:json[@"from"]];
    
    //    memberEvent.joinDate = json[@"body"][@"timestamp"][@"joined"]; // TODO: NSDate
    [self.delegate memberJoined:memberEvent];
}

- (void)onMemberInvited:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [[NXMMemberEvent alloc] initWithConversationId:json[@"cid"]
                                                                      sequenceId:[json[@"id"] integerValue]
                                                                        andState:NXMMemberStateInvited
                                                                         andData:json[@"body"]
                                                                    creationDate:[NXMUtils dateFromISOString:json[@"timestamp"]]
                                                                        memberId:json[@"from"]];
    
    [self.delegate memberInvited:memberEvent];
}

- (void)onMemberLeft:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [[NXMMemberEvent alloc] initWithConversationId:json[@"cid"]
                                                                      sequenceId:[json[@"id"] integerValue]
                                                                        andState:NXMMemberStateLeft
                                                                         andData:json[@"body"]
                                                                    creationDate:[NXMUtils dateFromISOString:json[@"timestamp"]]
                                                                        memberId:json[@"from"]];
    
    [self.delegate memberRemoved:memberEvent];
}


#pragma mark messages

- (void)onTextRecevied:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    
    NXMTextEvent *textEvent = [NXMTextEvent new];
    textEvent.text = json[@"body"][@"text"];
    textEvent.conversationId = json[@"cid"];
    textEvent.fromMemberId = json[@"from"];
    textEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    textEvent.sequenceId = [json[@"id"] integerValue];
    textEvent.type = NXMEventTypeText;
    
    [self.delegate textRecieved:textEvent];
    
}

- (void)onImageRecevied:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    
    NXMImageEvent *imageEvent = [[NXMImageEvent alloc] initWithConversationId:json[@"cid"]
                                                                   sequenceId:[json[@"id"] integerValue]
                                                                 fromMemberId:json[@"from"]
                                                                 creationDate:[NXMUtils dateFromISOString:json[@"timestamp"]]
                                                                         type:NXMEventTypeImage];
    NSDictionary *body = json[@"body"];
    imageEvent.imageId = body[@"id"];
    NSDictionary *originalJSON = body[@"original"];
    imageEvent.originalImage = [[NXMImageInfo alloc] initWithId:originalJSON[@"id"]
                                                             size:[originalJSON[@"size"] integerValue]
                                                              url:originalJSON[@"url"]
                                                             type:NXMImageTypeOriginal];
    
    NSDictionary *mediumJSON = body[@"medium"];
    imageEvent.mediumImage = [[NXMImageInfo alloc] initWithId:mediumJSON[@"id"]
                                                           size:[mediumJSON[@"size"] integerValue]
                                                            url:mediumJSON[@"url"]
                                                           type:NXMImageTypeMedium];
    
    
    NSDictionary *thumbnailJSON = body[@"thumbnail"];
    imageEvent.thumbnailImage = [[NXMImageInfo alloc] initWithId:thumbnailJSON[@"id"]
                                                              size:[thumbnailJSON[@"size"] integerValue]
                                                               url:thumbnailJSON[@"url"]
                                                              type:NXMImageTypeThumbnail];
    
    
    [self.delegate imageRecieved:imageEvent];
    
}

- (void)onMessageDeleted:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    
    NXMMessageStatusEvent *messageEvent = [NXMMessageStatusEvent new];
    messageEvent.eventId = [json[@"body"][@"event_id"] integerValue];
    messageEvent.conversationId = json[@"cid"];
    messageEvent.fromMemberId = json[@"from"];
    messageEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    messageEvent.sequenceId = [json[@"id"] integerValue];
    messageEvent.status = NXMMessageStatusTypeDeleted;
    messageEvent.type = NXMEventTypeMessageStatus;
    
    [self.delegate messageDeleted:messageEvent];
}

- (void)onTextSeen:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onTextSeen"];
    
    NSDictionary *json = data[0];
    NXMMessageStatusEvent *statusEvent = [NXMMessageStatusEvent new];
    statusEvent.eventId = [json[@"body"][@"event_id"] integerValue];
    statusEvent.conversationId = json[@"cid"];
    statusEvent.fromMemberId = json[@"from"];
    statusEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    statusEvent.sequenceId = [json[@"id"] integerValue];
    statusEvent.status = NXMMessageStatusTypeSeen;
    statusEvent.type = NXMEventTypeMessageStatus;
    
    [self.delegate textSeen:statusEvent];
}

- (void)onTextDelivered:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onTextDelivered"];
    
    NSDictionary *json = data[0];
    NXMMessageStatusEvent *statusEvent = [NXMMessageStatusEvent new];
    statusEvent.eventId = [json[@"body"][@"event_id"] integerValue];
    statusEvent.conversationId = json[@"cid"];
    statusEvent.fromMemberId = json[@"from"];
    statusEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    statusEvent.sequenceId = [json[@"id"] integerValue];
    statusEvent.status = NXMMessageStatusTypeDelivered;
    statusEvent.type = NXMEventTypeMessageStatus;
    
    [self.delegate textDelivered:statusEvent];
    
}

- (void)onImageSeen:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onImageSeen"];
    
    NSDictionary *json = data[0];
    NXMMessageStatusEvent *statusEvent = [NXMMessageStatusEvent new];
    statusEvent.eventId = [json[@"body"][@"event_id"] integerValue];
    statusEvent.conversationId = json[@"cid"];
    statusEvent.fromMemberId = json[@"from"];
    statusEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    statusEvent.sequenceId = [json[@"id"] integerValue];
    statusEvent.status = NXMMessageStatusTypeSeen;
    statusEvent.type = NXMEventTypeMessageStatus;
    
    [self.delegate imageSeen:statusEvent];
}

- (void)onImageDelivered:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onImagDelivered"];
    
    NSDictionary *json = data[0];
    NXMMessageStatusEvent *statusEvent = [NXMMessageStatusEvent new];
    statusEvent.eventId = [json[@"body"][@"event_id"] integerValue];
    statusEvent.conversationId = json[@"cid"];
    statusEvent.fromMemberId = json[@"from"];
    statusEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    statusEvent.sequenceId = [json[@"id"] integerValue];
    statusEvent.status = NXMMessageStatusTypeDelivered;
    statusEvent.type = NXMEventTypeMessageStatus;
    
    [self.delegate imageDelivered:statusEvent];
}

#pragma mark typing
- (void)onTextTypingOn:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onTextTypingOn"];
    NSDictionary *json = data[0];
    
    NXMTextTypingEvent *textTypingEvent = [NXMTextTypingEvent new];
    textTypingEvent.conversationId = json[@"cid"];
    textTypingEvent.fromMemberId = json[@"from"];
    textTypingEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    textTypingEvent.sequenceId = [json[@"id"] integerValue];
    textTypingEvent.status = NXMTextTypingEventStatusOn;
    textTypingEvent.type = NXMEventTypeTextTyping;
    
    [self.delegate textTypingOn:textTypingEvent];
}

- (void)onTextTypingOff:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onTextTypingOff"];
    NSDictionary *json = data[0];
    
    NXMTextTypingEvent *textTypingEvent = [NXMTextTypingEvent new];
    textTypingEvent.conversationId = json[@"cid"];
    textTypingEvent.fromMemberId = json[@"from"];
    textTypingEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    textTypingEvent.sequenceId = [json[@"id"] integerValue];
    textTypingEvent.status = NXMTextTypingEventStatusOff;
    textTypingEvent.type = NXMEventTypeTextTyping;
    
    [self.delegate textTypingOff:textTypingEvent];
}
#pragma mark media sip

- (void)onSipRinging:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMSipEvent * sipEvent = [self fillSipEventFromJson:json];
    sipEvent.sipType = NXMSipEventRinging;
    
    [self.delegate sipRinging:sipEvent];
}
- (void)onSipAnswered:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMSipEvent * sipEvent = [self fillSipEventFromJson:json];
    sipEvent.sipType = NXMSipEventAnswered;
    
    [self.delegate sipAnswered:sipEvent];
}
- (void)onSipHangup:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMSipEvent * sipEvent = [self fillSipEventFromJson:json];
    sipEvent.sipType = NXMSipEventHangup;
    
    [self.delegate sipHangup:sipEvent];
}
- (void)onSipStatus:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMSipEvent * sipEvent = [self fillSipEventFromJson:json];
    sipEvent.sipType = NXMSipEventStatus;
    
    [self.delegate sipStatus:sipEvent];
}

- (void)onLegStatus:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMLegStatusEvent * legStatusEvent = [self fillLegStatusEventFromJson:json];
    //legStatusEvent.sipType = NXMSipEventStatus;
    
    [self.delegate legStatus:legStatusEvent];
}

- (NXMLegStatusEvent*) fillLegStatusEventFromJson:(NSDictionary*) json{
    
    NSMutableArray<NXMLeg*> *legs = [[NSMutableArray<NXMLeg*> alloc] init];
    for (NSDictionary* currLeg in [json[@"body"] objectForKey:@"statusHistory"]){
        NXMLeg* leg = [[NXMLeg alloc] initWithData:json[@"body"] andLegData:currLeg];
        [legs addObject:leg];
    }
    NXMLegStatusEvent * legStatusEvent= [[NXMLegStatusEvent alloc]
                                         initWithConversationId:json[@"cid"]
                                         type:NXMEventTypeLegStatus
                                         fromMemberId:json[@"from"]
                                         sequenceId:[json[@"id"] integerValue]
                                         legHistory:legs];
    return legStatusEvent;
}
                                                  
- (NXMSipEvent*) fillSipEventFromJson:(NSDictionary*) json{
    NXMSipEvent * sipEvent= [NXMSipEvent new];
    sipEvent.fromMemberId = json[@"from"];
    sipEvent.sequenceId = [json[@"id"] integerValue];
    sipEvent.conversationId = json[@"cid"];
    sipEvent.phoneNumber = json[@"body"][@"channel"][@"to"][@"number"];
    sipEvent.applicationId = json[@"application_id"];
    sipEvent.type = NXMEventTypeSip;
    return sipEvent;
}
#pragma mark media rtc

- (void)onRTCAnswer:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    
    NXMRtcAnswerEvent *mediaEvent = [NXMRtcAnswerEvent new];
    mediaEvent.conversationId = json[@"cid"];
    mediaEvent.sessionId = json[@"session_destination"];
    mediaEvent.timestamp = json[@"timestamp"];
    mediaEvent.sdp = json[@"body"][@"answer"];
    mediaEvent.rtcId = json[@"body"][@"rtc_id"];
    
    [self.delegate rtcAnswerEvent:mediaEvent];
}


- (void)onRTCTerminate:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    // TODO:
    // should we use it? should we use member media?
    //    {
    //        "timestamp": 1525248500583,
    //        "type": "rtc:terminate",
    //        "payload": {
    //            "cid": "CON-b2b067e6-ef07-45e5-a9f3-138e66373359",
    //            "from": "MEM-164379b3-a819-4964-99a0-bfaed993d739",
    //            "rtc_id": "70bbf7bc-c2fc-4f51-9946-d974b2fc521a"
    //        },
    //        "direction": "emitted"
    //    }
}

- (void)onRTCMemberMedia:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    
    NXMMediaEvent *mediaEvent = [NXMMediaEvent new];
    mediaEvent.conversationId = json[@"cid"];
    mediaEvent.fromMemberId = json[@"from"];
    mediaEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    mediaEvent.sequenceId = [json[@"id"] integerValue];
    mediaEvent.mediaSettings = [NXMMediaSettings new];
    mediaEvent.mediaSettings.isEnabled = [json[@"body"][@"media"][@"audio_settings"][@"enabled"] boolValue];
    mediaEvent.mediaSettings.isSuspended = [json[@"body"][@"media"][@"audio_settings"][@"muted"] boolValue];
    mediaEvent.type = NXMEventTypeMedia;
    
    [self.delegate mediaEvent:mediaEvent];
}

- (void)onRTCAudioMuteOn:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    
    NXMMediaSuspendEvent *mediaEvent = [NXMMediaSuspendEvent new];
    mediaEvent.toMemberId = json[@"to"];
    mediaEvent.conversationId = json[@"cid"];
    mediaEvent.fromMemberId = json[@"from"];
    mediaEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    mediaEvent.sequenceId = [json[@"id"] integerValue];
    mediaEvent.type = NXMEventTypeMediaAction;
    mediaEvent.actionType = NXMMediaActionTypeSuspend;
    mediaEvent.mediaType = NXMMediaTypeAudio;
    mediaEvent.isSuspended = true;
    
    [self.delegate mediaActionEvent:mediaEvent];
}

- (void)onRTCAudioMuteOff:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    
    NXMMediaSuspendEvent *mediaEvent = [NXMMediaSuspendEvent new];
    mediaEvent.toMemberId = json[@"to"];
    mediaEvent.conversationId = json[@"cid"];
    mediaEvent.fromMemberId = json[@"from"];
    mediaEvent.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    mediaEvent.sequenceId = [json[@"id"] integerValue];
    mediaEvent.type = NXMEventTypeMediaAction;
    mediaEvent.actionType = NXMMediaActionTypeSuspend;
    mediaEvent.mediaType = NXMMediaTypeAudio;
    mediaEvent.isSuspended = false;
    
    [self.delegate mediaActionEvent:mediaEvent];
}

- (void)onAudioDTMF:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {

    NSDictionary *json = data[0];
    
    NXMDTMFEvent *event = [[NXMDTMFEvent alloc] initWithDigit:json[@"body"][@"digit"]
                                                   andDuration:[NSNumber numberWithInteger:[json[@"body"][@"duration"] integerValue]]];
    event.conversationId = json[@"cid"];
    event.fromMemberId = json[@"from"];
    event.creationDate = [NXMUtils dateFromISOString:json[@"timestamp"]];
    event.sequenceId = [json[@"id"] integerValue];
    event.type = NXMEventTypeDTMF;
    
    [self.delegate DTMFEvent:event];
}

@end
