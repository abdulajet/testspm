//
//  NXMSocketClient.m
//  StitchObjC
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPSocketIO.h"

#import "NXMSocketClient.h"
#import "NXMSocketClientDefine.h"

#import "NXMLogger.h"
#import "NXMErrors.h"

#import "NXMCoreEvents.h"
#import "NXMRtcAnswerEvent.h"

#import "NXMUtils.h"

@interface NXMSocketClient()

@property BOOL isLoggedIn;
@property id<NXMSocketClientDelegate> delegate;
@property VPSocketIOClient *socket;
@property NSString *token;
@property NXMUser *user;

@end

@implementation NXMSocketClient

static NSString *const nxmURL = @"https://api.nexmo.com/beta";

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
                                                       @"reconnectWait":@10,
                                                       @"reconnectAttempts": @3,
                                                       @"nsp":@"/",
                                                       @"connectParams":connectParams,
                                                       @"logger":logger
                                                       }];
        
        [self subscribeSocketEvent];
    }
    
    return self;
}
#pragma mark login

- (BOOL)isSocketConnected {
    return self.socket.status == VPSocketIOClientStatusNotConnected;
}

- (void)loginWithToken:(NSString *)token {
    self.token = token;
    [self connectSocket];
}

- (void)refreshAuthToken:(nonnull NSString *)authToken {
    self.token = authToken;
    
    NSDictionary * msg = @{ @"body" : @{
                                    @"token":authToken
                                    }};
    
    [self.socket emit:kNXMSocketEventRefreshToken items:@[msg]];
}

- (void)logout {
    if(self.isLoggedIn) {
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

- (void)didSocketConnect {
    [NXMLogger debug:@"socket connected"];
    [self.delegate connectionStatusChanged:YES];
    //TODO: question - what happens if we try to log in while already logged in to the server for example after a reconnect?
    [self serverLogin];
}

- (void)didSocketDisconnect{
    [self.delegate connectionStatusChanged:NO];
    //TODO: this might mean that a logout happend on the server side
}

- (void)socketDidChangeStatus {
    switch (self.socket.status) {
        case VPSocketIOClientStatusConnected:
            [NXMLogger debug:@"socket connected"];
            [self didSocketConnect];
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
            [self didSocketDisconnect];
            break;
        case VPSocketIOClientStatusOpened:
            [NXMLogger debug:@"socket opened"];
            [self didSocketDisconnect];
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
                                   }};
    
    [self.socket emit:kNXMSocketEventLogin items:@[msg]];
}

- (void)serverLogout {
    NSDictionary * msg = @{@"tid": [[NSUUID UUID] UUIDString]};
    [self.socket emit:kNXMSocketEventLogout items:@[msg]];
}
//    NXMUser * user = self.user;
//    self.token = nil;
//    self.user = nil;
//    [self.delegate didLogout:user];
//}

- (void)didFailLoginWithError:(NSError *)error {
    self.isLoggedIn = NO;
    self.user = nil;
    self.token = nil;
    [self disconnectSocket];
    [self.delegate loginStatusChangedWithUser:self.user sessionId:nil isLoggedIn:self.isLoggedIn error:error];
    
}

- (void)didServerLoginWithData:(NSArray *)data {
    self.isLoggedIn = YES;
    NSDictionary *response = ((NSDictionary *)data[0])[@"body"];
    NXMUser *user = [[NXMUser alloc] initWithId:response[@"user_id"] name:response[@"name"]];
    self.user = user;
    NSString * sessionid = response[@"id"];
    [self.delegate loginStatusChangedWithUser:self.user sessionId:sessionid isLoggedIn:self.isLoggedIn error:nil];
}

- (void)didServerLogout {
    [NXMLogger debug:@"did server logout"];
    self.isLoggedIn = NO;
    NXMUser *byeByeUser = self.user;
    self.user = nil;
    self.token = nil;
    [self.delegate loginStatusChangedWithUser:byeByeUser sessionId:nil isLoggedIn:NO error:nil];
    [self disconnectSocket];
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
}

- (void)subscribeVPSocketEvents {

    [self.socket on:kSocketEventStatusChange callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self socketDidChangeStatus];
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
    [self.socket on:kNXMSocketEventLoginSuccess callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"socketLoginSuccess"];
        [self didServerLoginWithData:data];
    }];
    
    [self.socket on:kNXMSocketEventSessionLogoutSuccess callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"socketLogoutSuccess"];
        [self didServerLogout];
    }];
    
    [self.socket on:kNXMSocketEventSessionTerminated callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"socketSessionTerminated"];
        [self didServerLogout];
    }];
    
    [self.socket on:kNXMSocketEventSessionInvalid callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventSessionInvalid"];
        NSError *error = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeSessionInvalid andUserInfo:nil];
        [self didFailLoginWithError:error];
    }];
    
    [self.socket on:kNXMSocketEventSessionErrorInvalid callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventSessionErrorInvalid"];
        NSError *error = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeSessionInvalid andUserInfo:nil];
        [self didFailLoginWithError:error];
    }];
    
    [self.socket on:kNXMSocketEventMaxOpenedSessions callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventMaxOpenedSessions"];
        NSError *error = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeMaxOpenedSessions andUserInfo:nil];
        [self didFailLoginWithError:error];
    }];
    
    [self.socket on:kNXMSocketEventInvalidToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSDictionary * userInfo = @{@"token" : self.token};
        [NXMLogger warning:@"!!!!socket kNXMSocketEventInvalidToken"];
        NSError *error = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeTokenInvalid andUserInfo:userInfo];
        [self didFailLoginWithError:error]; //TODO: check if this might happen without meaning a logout
    }];
    
    [self.socket on:kNXMSocketEventExpiredToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventExpiredToken"];
        NSDictionary * userInfo = @{@"token" : self.token};
        NSError *error = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeTokenExpired andUserInfo:userInfo];
        [self didFailLoginWithError:error]; //TODO: check if this might happen without meaning a logout
    }];
    
    [self.socket on:kNXMSocketEventRefreshTokenDone callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventRefreshTokenDone"];
        [self.delegate didRefreshToken];
    }];
}

- (void)subscribeMemberEvents {
    [self.socket on:kNXMSocketEventMemberJoined callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventMemberJoined"];
        [self onMemberJoined:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMemberInvited callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventMemberInvited"];
        [self onMemberInvited:data emitter:emitter];
    }];
    
    
    [self.socket on:kNXMSocketEventMemberLeft callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventMemberLeft"];
        [self onMemberLeft:data emitter:emitter];
    }];
}

- (void)subscribeTextEvents {
    [self.socket on:kNXMSocketEventText callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventText"];
        [self onTextRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextSuccess callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTextSuccess"];
     //   [self onTextRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMessageDelete callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTextDelete"];
        [self onMessageDeleted:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextSeen callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTextSeen"];
        [self onTextSeen:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextDelivered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTextDelivered"];
        [self onTextDelivered:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImage callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventImage"];
        [self onImageRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImageSeen callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventImageSeen"];
        [self onImageSeen:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImageDelivered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventImageDelivered"];
        [self onImageDelivered:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTypingOn callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTypingOn"];
        [self onTextTypingOn:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTypingOff callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTypingOff"];
        [self onTextTypingOff:data emitter:emitter];
    }];
}

- (void)subscribeRTCEvents {
    [self.socket on:kNXMSocketEventRtcAnswer callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventRtcAnswer"];
        [self onRTCAnswer:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMemebrMedia callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventMemebrMedia"];
        [self onRTCMemberMedia:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventAudioMuteOn callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventAudioMuteOn"];
        [self onRTCAudioMuteOn:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventAudioMuteOff callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventAudioMuteOff"];
        [self onRTCAudioMuteOff:data emitter:emitter];
    }];
}
- (void)subscribeSipEvents{
    [self.socket on:kNXMSocketEventSipRinging callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventSipRinging"];
        [self onSipRinging:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventSipAnswered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventSipAnswered"];
        [self onSipAnswered:data emitter:emitter];
    }];

    [self.socket on:kNXMSocketEventSipHangup callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventSipHangup"];
        [self onSipHangup:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventSipStatus callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventSipStatus"];
        [self onSipStatus:data emitter:emitter];
    }];
}

#pragma mark - Socket Events
#pragma mark members
- (void)onMemberJoined:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [NXMMemberEvent new];
    memberEvent.memberId = json[@"from"];
    memberEvent.user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"user_id"] name:json[@"body"][@"user"][@"name"]];
    //    memberEvent.joinDate = json[@"body"][@"timestamp"][@"joined"]; // TODO: NSDate
    memberEvent.sequenceId = [json[@"id"] integerValue];
    memberEvent.state = NXMMemberStateJoined;
    memberEvent.conversationId = json[@"cid"];
    memberEvent.phoneNumber = json[@"body"][@"channel"][@"to"][@"number"];
    memberEvent.type = NXMEventTypeMember;
    memberEvent.name = json[@"body"][@"user"][@"name"]; //TODO - make sure with cs that this is indeed the name, and the payload is correct
    [self.delegate memberJoined:memberEvent];
}

- (void)onMemberInvited:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    NXMUser *user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"user_id"] name:json[@"body"][@"user"][@"name"]];
    NXMMediaSettings *mediaSettings = [[NXMMediaSettings alloc] initWithEnabled:(json[@"body"][@"media"] != nil ? YES : NO) suspend:NO];
    
    NXMMemberEvent *memberEvent = [[NXMMemberEvent alloc] initWithConversationId:json[@"cid"]
                                                                            type:NXMEventTypeMember
                                                                    fromMemberId:json[@"invited_by"]
                                                                      sequenceId:[json[@"id"] integerValue]
                                                                        memberId:json[@"from"]
                                                                            name:json[@"body"][@"user"][@"name"]
                                                                           state:NXMMemberStateInvited
                                                                            user:user
                                                                     phoneNumber:json[@"body"][@"channel"][@"to"][@"number"]
                                                                           media:mediaSettings];


    [self.delegate memberInvited:memberEvent];
}

- (void)onMemberLeft:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [NXMMemberEvent new];
    memberEvent.memberId = json[@"from"];
    memberEvent.user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"id"] name:json[@"body"][@"user"][@"name"]];
    //    memberEvent.joinDate = json[@"body"][@"timestamp"][@"joined"]; // TODO: NSDate
    //    memberEvent.leftDate = json[@"body"][@"timestamp"][@"left"]; // TODO: NSDate
    memberEvent.sequenceId = [json[@"id"] integerValue];
    memberEvent.state = NXMMemberStateLeft;
    memberEvent.conversationId = json[@"cid"];
    memberEvent.phoneNumber = json[@"body"][@"channel"][@"to"][@"number"];
    memberEvent.type = NXMEventTypeMember;
    memberEvent.name = json[@"body"][@"user"][@"name"]; //TODO - make sure with cs that this is indeed the name, and the payload is correct
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

@end
