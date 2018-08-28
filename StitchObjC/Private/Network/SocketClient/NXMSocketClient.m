
//
//  SocketClient.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VPSocketIO/VPSocketIO.h>

#import "NXMSocketClient.h"
#import "NXMSocketClientDefine.h"

#import "NXMLogger.h"
#import "NXMErrors.h"

#import "NXMConversationEvents.h"
#import "NXMRtcAnswerEvent.h"

@interface NXMSocketClient()

@property BOOL isWSOpen;
@property BOOL isLoggedIn;
@property id<NXMSocketClientDelegate> delegate;
@property VPSocketIOClient *socket;
@property NSString *token;

@end

@implementation NXMSocketClient

static NSString *const nxmURL = @"https://api.nexmo.com/beta";

#pragma Public

- (void)close {

}

- (instancetype)initWitHost:(NSString *)host {
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
                                                        @"reconnectWait":@1000,
                                                        @"nsp":@"/",
                                                        @"connectParams":connectParams,
                                                        @"logger":logger
                                                        }];
        
        [self subscribeSocketEvent];
    }
    
    return self;
}

- (BOOL)isSocketOpen {
    return self.isWSOpen;
}


- (void)loginWithToken:(NSString *)token {
    self.token = token;
    if (!self.isWSOpen) {
        [self.socket connect];
    }
    
    [self login];
}

- (void)logout {
    // TODO: socket client logout
}


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

- (void)login {
    // TODO: device id
    NSDictionary * msg = @{@"tid": [[NSUUID UUID] UUIDString],
                           @"body" : @{
                           @"token": self.token,
                           @"device_id": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                           @"device_type": @"iphone",
                           }};
    
    [self.socket emit:kNXMSocketEventLogin items:@[msg]];
}

- (void)subscribeSocketEvent {
    [self subscribeSocketGeneralEvents];
    [self subscribeLoginEvents];
    [self subscribeMemberEvents];
    [self subscribeTextEvents];
    [self subscribeRTCEvents];
    [self subscribeSipEvents];
}

- (void)subscribeSocketGeneralEvents {
    [self.socket on:kSocketEventConnect callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"socket connected event when already connceted"];
        
        if (self.isWSOpen) { return; }
        
        [NXMLogger debug:@"socket connected"];

        self.isWSOpen = YES;
        
        [self.delegate connectionStatusChanged:YES];
        
        [self login];
    }];
    
    [self.socket on:kSocketEventDisconnect callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"socket disconnected"];
        if (!self.isWSOpen) {return;}

        self.isWSOpen = NO;
        self.isLoggedIn = NO;
        
        [self.delegate connectionStatusChanged:NO];
    }];
    
    [self.socket on:kSocketEventError callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"socket error"];
    }];
    
    [self.socket on:kNXMSocketEventError callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"socket event error"];
    }];
}

- (void)subscribeLoginEvents {
    [self.socket on:kNXMSocketEventLoginSuccess callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        if (self.isLoggedIn) {return;}
        
        self.isLoggedIn = YES;
        NSDictionary *response = ((NSDictionary *)data[0])[@"body"];
        NXMUser *user = [[NXMUser alloc] initWithId:response[@"user_id"] name:response[@"name"]];
        
        [self.delegate userStatusChanged:user sessionId:response[@"id"]];
    }];
    
    [self.socket on:kNXMSocketEventSessionInvalid callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventSessionInvalid"];
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventInvalidToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventInvalidToken"];
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventExpiredToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventExpiredToken"];
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventBadPermission callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket BadPermission"];
    }];
    
    [self.socket on:kNXMSocketEventInvalidEvent callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventInvalidEvent"];
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventUserNotFound callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger warning:@"!!!!socket kNXMSocketEventUserNotFound"];
        [self onLoginFailed:data emitter:emitter];
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
    
    [self.socket on:kNXMSocketEventTextDelete callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventTextDelete"];
        [self onTextDeleted:data emitter:emitter];
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
        [self onTextImageSeen:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImageDelivered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"!!!!socket kNXMSocketEventImageDelivered"];
        [self onTextImageDelivered:data emitter:emitter];
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

#pragma socket event handle
- (void)onLoginFailed:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    if (!self.isLoggedIn) { return; }
    
    self.isLoggedIn = NO;
    
    [self.delegate userStatusChanged:nil sessionId:nil];
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
// member events handle
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
- (void)onMemberJoined:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [NXMMemberEvent new];
    memberEvent.memberId = json[@"from"];
    memberEvent.user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"user_id"] name:json[@"body"][@"user"][@"name"]];
//    memberEvent.joinDate = json[@"body"][@"timestamp"][@"joined"]; // TODO: NSDate
    memberEvent.sequenceId = [json[@"id"] integerValue];
    memberEvent.state = @"JOINED";
    memberEvent.conversationId = json[@"cid"];
    memberEvent.phoneNumber = json[@"body"][@"channel"][@"to"][@"number"];
    memberEvent.type = NXMEventTypeMember;
    [self.delegate memberJoined:memberEvent];
}

- (void)onMemberInvited:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [NXMMemberEvent new];
    memberEvent.memberId = json[@"from"];
    memberEvent.user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"user_id"] name:json[@"body"][@"user"][@"name"]];
    //    memberEvent.joinDate = json[@"body"][@"timestamp"][@"joined"]; // TODO: NSDate
    memberEvent.sequenceId = [json[@"id"] integerValue];
    memberEvent.state = @"INVITED";
    memberEvent.conversationId = json[@"cid"];
    memberEvent.phoneNumber = json[@"body"][@"channel"][@"to"][@"number"];
    memberEvent.type = NXMEventTypeMember;
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
    memberEvent.state = @"LEFT";
    memberEvent.conversationId = json[@"cid"];
    memberEvent.phoneNumber = json[@"body"][@"channel"][@"to"][@"number"];
    memberEvent.type = NXMEventTypeMember;
    [self.delegate memberRemoved:memberEvent];
}

#pragma text event handle

- (void)onTextRecevied:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    
    NXMTextEvent *textEvent = [NXMTextEvent new];
    textEvent.text = json[@"body"][@"text"];
    textEvent.conversationId = json[@"cid"];
    textEvent.fromMemberId = json[@"from"];
    textEvent.creationDate = json[@"timestamp"];
    textEvent.sequenceId = [json[@"id"] integerValue];
    textEvent.type = NXMEventTypeText;
    
    [self.delegate textRecieved:textEvent];
    
}

- (void)onImageRecevied:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    
    NXMImageEvent *imageEvent = [[NXMImageEvent alloc] initWithConversationId:json[@"cid"]
                                                                  sequenceId:[json[@"id"] integerValue]
                                                                fromMemberId:json[@"from"]
                                                                creationDate:json[@"timestamp"]
                                                                        type:NXMEventTypeImage];
    NSDictionary *body = json[@"body"];
    imageEvent.imageId = body[@"id"];
    NSDictionary *originalJSON = body[@"original"];
    imageEvent.originalImage = [[NXMImageInfo alloc] initWithUuid:originalJSON[@"id"]
                                                             size:[originalJSON[@"size"] integerValue]
                                                              url:originalJSON[@"url"]
                                                             type:NXMImageTypeOriginal];
     
    NSDictionary *mediumJSON = body[@"medium"];
    imageEvent.mediumImage = [[NXMImageInfo alloc] initWithUuid:mediumJSON[@"id"]
                                                             size:[mediumJSON[@"size"] integerValue]
                                                              url:mediumJSON[@"url"]
                                                             type:NXMImageTypeMedium];
    
    
    NSDictionary *thumbnailJSON = body[@"thumbnail"];
    imageEvent.thumbnailImage = [[NXMImageInfo alloc] initWithUuid:thumbnailJSON[@"id"]
                                                             size:[thumbnailJSON[@"size"] integerValue]
                                                              url:thumbnailJSON[@"url"]
                                                             type:NXMImageTypeThumbnail];
    
    
    [self.delegate imageRecieved:imageEvent];
    
}

- (void)onTextDeleted:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    
    NXMTextStatusEvent *textEvent = [NXMTextStatusEvent new];
    textEvent.eventId = [json[@"body"][@"event_id"] integerValue];
    textEvent.conversationId = json[@"cid"];
    textEvent.fromMemberId = json[@"from"];
    textEvent.creationDate = json[@"timestamp"];
    textEvent.sequenceId = [json[@"id"] integerValue];
    textEvent.status = NXMTextEventStatusEDeleted;
    textEvent.type = NXMEventTypeTextStatus;
    
    [self.delegate textDeleted:textEvent];
}

- (void)onTextSeen:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onTextSeen"];
    
    NSDictionary *json = data[0];
    NXMTextStatusEvent *textEvent = [NXMTextStatusEvent new];
    textEvent.eventId = [json[@"body"][@"event_id"] integerValue];
    textEvent.conversationId = json[@"cid"];
    textEvent.fromMemberId = json[@"from"];
    textEvent.creationDate = json[@"timestamp"];
    textEvent.sequenceId = [json[@"id"] integerValue];
    textEvent.status = NXMTextEventStatusESeen;
    textEvent.type = NXMEventTypeTextStatus;
    
    [self.delegate textSeen:textEvent];
}

- (void)onTextDelivered:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onTextDelivered"];
    
    NSDictionary *json = data[0];
    NXMTextStatusEvent *textEvent = [NXMTextStatusEvent new];
    textEvent.eventId = [json[@"body"][@"event_id"] integerValue];
    textEvent.conversationId = json[@"cid"];
    textEvent.fromMemberId = json[@"from"];
    textEvent.creationDate = json[@"timestamp"];
    textEvent.sequenceId = [json[@"id"] integerValue];
    textEvent.status = NXMTextEventStatusEDelivered;
    textEvent.type = NXMEventTypeTextStatus;
    
    [self.delegate textDelivered:textEvent];
    
}

- (void)onTextImageSeen:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onTextImageDelivered:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onTextTypingOn:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onTextTypingOn"];
    NSDictionary *json = data[0];
    
    NXMTextTypingEvent *textEvent = [NXMTextTypingEvent new];
    textEvent.conversationId = json[@"cid"];
    textEvent.fromMemberId = json[@"from"];
    textEvent.creationDate = json[@"timestamp"];
    textEvent.sequenceId = [json[@"id"] integerValue];
    textEvent.status = NXMTextTypingEventStatusOn;
    textEvent.type = NXMEventTypeTextTyping;
    
    [self.delegate textTypingOn:textEvent];
}

- (void)onTextTypingOff:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    [NXMLogger debug:@"onTextTypingOff"];
    NSDictionary *json = data[0];
    
    NXMTextTypingEvent *textEvent = [NXMTextTypingEvent new];
    textEvent.conversationId = json[@"cid"];
    textEvent.fromMemberId = json[@"from"];
    textEvent.creationDate = json[@"timestamp"];
    textEvent.sequenceId = [json[@"id"] integerValue];
    textEvent.status = NXMTextTypingEventStatusOff;
    textEvent.type = NXMEventTypeTextTyping;
    
    [self.delegate textTypingOff:textEvent];
}

#pragma mark - rtc event handle

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
    mediaEvent.creationDate = json[@"timestamp"];
    mediaEvent.sequenceId = [json[@"id"] integerValue];
    mediaEvent.mediaSettings = [NXMMediaSettings new];
    mediaEvent.mediaSettings.isEnabled = [json[@"body"][@"audio_settings"][@"enabled"] boolValue];
    mediaEvent.mediaSettings.isSuspended = [json[@"body"][@"audio_settings"][@"muted"] boolValue];
    mediaEvent.type = NXMEventTypeMedia;
    
    [self.delegate mediaEvent:mediaEvent];
}

- (void)onRTCAudioMuteOn:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    
    NXMMediaSuspendEvent *mediaEvent = [NXMMediaSuspendEvent new];
    mediaEvent.toMemberId = json[@"to"];
    mediaEvent.conversationId = json[@"cid"];
    mediaEvent.fromMemberId = json[@"from"];
    mediaEvent.creationDate = json[@"timestamp"];
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
    mediaEvent.creationDate = json[@"timestamp"];
    mediaEvent.sequenceId = [json[@"id"] integerValue];
    mediaEvent.type = NXMEventTypeMediaAction;
    mediaEvent.actionType = NXMMediaActionTypeSuspend;
    mediaEvent.mediaType = NXMMediaTypeAudio;
    mediaEvent.isSuspended = false;
    
    [self.delegate mediaActionEvent:mediaEvent];
}

@end
