
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

#import "NXMMemberEvent.h"
#import "NXMTextEvent.h"
#import "NXMTextStatusEvent.h"
#import "NXMTextTypingEvent.h"
#import "NXMMediaEvent.h"
#import "NXMMediaAnswerEvent.h"
#import "NXMErrors.h"

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
              eventId:(nonnull NSString *)eventId
{
    NSDictionary * msg = @{
                           @"cid": conversationId,
                           @"from":memberId,
                           @"body" : @{
                                   @"event_id":eventId
                                   }};
    
    [self.socket emit:kNXMSocketEventTextSeen items:@[msg]];
}


- (void)deliverTextEvent:(nonnull NSString *)conversationId
                memberId:(nonnull NSString *)memberId
                 eventId:(nonnull NSString *)eventId
{
    NSDictionary * msg = @{
                           @"cid": conversationId,
                           @"from":memberId,
                           @"body" : @{
                                   @"event_id":eventId
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
                           @"device_id": @"453534fdggh45y",
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
}

- (void)subscribeSocketGeneralEvents {
    [self.socket on:kSocketEventConnect callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"socket connected when already connceted"];
        
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
        [NXMLogger debug:@"socket error"];
    }];
    
    [self.socket on:kNXMSocketEventError callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [NXMLogger debug:@"socket event error"];
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
        NSLog(@"!!!!socket kNXMSocketEventSessionInvalid");
        //NSError *err = [[NSError alloc] initWithDomain:NXMStitchErrorDomain code:NXMStitchErrorCodeSessionInvalid userInfo:nil];
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventInvalidToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventInvalidToken");
        //NSError *err = [[NSError alloc] initWithDomain:NXMStitchErrorDomain code:NXMStitchErrorCodeTokenInvalid userInfo:nil];
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventExpiredToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventExpiredToken");
        //NSError *err = [[NSError alloc] initWithDomain:NXMStitchErrorDomain code:NXMStitchErrorCodeTokenExpired userInfo:nil];
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventBadPermission callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket BadPermission");
    }];
    
    [self.socket on:kNXMSocketEventInvalidEvent callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventInvalidEvent");
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventUserNotFound callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventUserNotFound");
        [self onLoginFailed:data emitter:emitter];
    }];
}

- (void)subscribeMemberEvents {
    [self.socket on:kNXMSocketEventMemberJoined callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventMemberJoined");
        [self onMemberJoined:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMemberInvited callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventMemberInvited");
        [self onMemberInvited:data emitter:emitter];
    }];
    
    
    [self.socket on:kNXMSocketEventMemberLeft callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventMemberLeft");
        [self onMemberLeft:data emitter:emitter];
    }];
}

- (void)subscribeTextEvents {
    [self.socket on:kNXMSocketEventText callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventText");
        [self onTextRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextSuccess callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventTextSuccess");
     //   [self onTextRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextDelete callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventTextDelete");
        [self onTextDeleted:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextSeen callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventTextSeen");
        [self onTextSeen:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextDelivered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventTextDelivered");
        [self onTextDelivered:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImage callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventImage");
        [self onImageRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImageSeen callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventImageSeen");
        [self onTextImageSeen:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImageDelivered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventImageDelivered");
        [self onTextImageDelivered:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTypingOn callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventTypingOn");
        [self onTextTypingOn:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTypingOff callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventTypingOff");
        [self onTextTypingOff:data emitter:emitter];
    }];
}

- (void)subscribeRTCEvents {
    [self.socket on:kNXMSocketEventRtcAnswer callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventRtcAnswer");
        [self onRTCAnswer:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMemebrMedia callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventMemebrMedia");
        [self onRTCMemberMedia:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventAudioMuteOn callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventAudioMuteOn");
        [self onRTCMuteOn:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventAudioMuteOff callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket kNXMSocketEventAudioMuteOff");
        [self onRTCMuteOff:data emitter:emitter];
    }];
}

#pragma socket event handle
- (void)onLoginFailed:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    if (!self.isLoggedIn) { return; }
    
    self.isLoggedIn = NO;
    
    [self.delegate userStatusChanged:nil sessionId:nil];
}

// member events handle

- (void)onMemberJoined:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [NXMMemberEvent new];
    memberEvent.memberId = json[@"from"];
    memberEvent.user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"user_id"] name:json[@"body"][@"user"][@"name"]];
//    memberEvent.joinDate = json[@"body"][@"timestamp"][@"joined"]; // TODO: NSDate
    memberEvent.sequenceId = [json[@"id"] integerValue];
    memberEvent.state = @"JOINED";
    memberEvent.conversationId = json[@"cid"];
    
    
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
    NSDictionary *body = json[@"body"][@"representations"];
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
    textEvent.eventId = json[@"body"][@"event_id"];
    textEvent.conversationId = json[@"cid"];
    textEvent.fromMemberId = json[@"from"];
    textEvent.creationDate = json[@"timestamp"];
    textEvent.sequenceId = [json[@"id"] integerValue];
    textEvent.status = NXMTextEventStatusEDeleted;
    textEvent.type = NXMEventTypeTextStatus;
    
    [self.delegate textDeleted:textEvent];
}

- (void)onTextSeen:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSLog(@"onTextSeen");
    
    NSDictionary *json = data[0];
    NXMTextStatusEvent *textEvent = [NXMTextStatusEvent new];
    textEvent.eventId = json[@"body"][@"event_id"];
    textEvent.conversationId = json[@"cid"];
    textEvent.fromMemberId = json[@"from"];
    textEvent.creationDate = json[@"timestamp"];
    textEvent.sequenceId = [json[@"id"] integerValue];
    textEvent.status = NXMTextEventStatusESeen;
    textEvent.type = NXMEventTypeTextStatus;
    
    [self.delegate textSeen:textEvent];
}

- (void)onTextDelivered:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSLog(@"onTextDelivered");
    
    NSDictionary *json = data[0];
    NXMTextStatusEvent *textEvent = [NXMTextStatusEvent new];
    textEvent.eventId = json[@"body"][@"event_id"];
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
    NSLog(@"onTextTypingOn");
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
    NSLog(@"onTextTypingOff");
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
    
    NXMMediaAnswerEvent *mediaEvent = [NXMMediaAnswerEvent new];
    mediaEvent.conversationId = json[@"cid"];
    mediaEvent.sessionId = json[@"session_destination"];
    mediaEvent.timestamp = json[@"timestamp"];
    mediaEvent.sdp = json[@"body"][@"answer"];
    mediaEvent.rtcId = json[@"body"][@"rtc_id"];
    
    [self.delegate mediaAnswerEvent:mediaEvent];
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
    mediaEvent.isMediaEnabled = [json[@"body"][@"audio"] boolValue];
    mediaEvent.type = NXMEventTypeMedia;
    
    [self.delegate mediaEvent:mediaEvent];
}

- (void)onRTCMuteOn:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onRTCMuteOff:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

@end
