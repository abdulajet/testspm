
//
//  SocketClient.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXMSocketClient.h"
#import "NXMSocketClientDefine.h"

#import <VPSocketIO/VPSocketIO.h>
#import "NXMMemberEvent.h"

@interface NXMSocketClient()

typedef void (^ResponseBlock)(NSError*, NSObject*);


@property BOOL isWSOpen;
@property BOOL isLoggedIn;
@property id<NXMSocketClientDelegate> delegate;
@property VPSocketIOClient *socket;
@property NSString *token;
@property NSMutableDictionary* responseBlockDictionary;
@end

@implementation NXMSocketClient

static NSString *const nxmURL = @"https://api.nexmo.com/beta";

#pragma Public

- (void)close {

}

- (instancetype)initWitHost:(NSString *)host {
    if (self = [super init]) {
        self.responseBlockDictionary = [[NSMutableDictionary alloc] init];
        
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

- (void)sendText:(nonnull NSString *)text
  conversationId:(nonnull NSString *)conversationId
    fromMemberId:(nonnull NSString *)fromMemberId {
    
    NSDictionary * msg = @{ @"tid": [[NSUUID UUID] UUIDString],
                               @"cid": conversationId,
                               @"from": fromMemberId,
                               @"body": @{
                                       @"text": text
                            }};
    
    
    [self.socket emit:kNXMSocketEventText items:@[msg]];
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
  //  [self sendRequestWithMSG:kNXMSocketEventLogin msg:msg requestId:[[NSUUID UUID] UUIDString]];
}

- (void)subscribeSocketEvent {
    [self subscribeSocketGeneralEvents];
    [self subscribeLoginEvents];
    [self subscribeMemberEvents];
    [self subscribeTextEvents];
    [self subscribeRTCEvents];
    [self subscribeRequestEvents];
}

- (void)subscribeSocketGeneralEvents {
    [self.socket on:kSocketEventConnect callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (self.isWSOpen) {return;}
        
        self.isWSOpen = YES;
        
        [self.delegate connectionStatusChanged:YES];
        
        [self login];
    }];
    
    [self.socket on:kSocketEventDisconnect callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket disconnected");
        if (!self.isWSOpen) {return;}

        self.isWSOpen = NO;
        self.isLoggedIn = NO;
        
        [self.delegate connectionStatusChanged:NO];
    }];
    
    [self.socket on:kSocketEventError callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket errorrrr");
    }];
    
    [self.socket on:kNXMSocketEventError callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket errorrrr");
    }];
}

- (void)subscribeLoginEvents {
    [self.socket on:kNXMSocketEventLoginSuccess callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        if (self.isLoggedIn) {return;}
        
        self.isLoggedIn = YES;
        NSDictionary *response = ((NSDictionary *)data[0])[@"body"];
        NXMUser *user = [[NXMUser alloc] initWithId:response[@"user_id"] name:response[@"name"]];
        [self.delegate userStatusChanged:user];
    }];
    
    [self.socket on:kNXMSocketEventSessionInvalid callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventInvalidToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventExpiredToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventBadPermission callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket BadPermission");
    }];
    
    [self.socket on:kNXMSocketEventInvalidEvent callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onLoginFailed:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventUserNotFound callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onLoginFailed:data emitter:emitter];
    }];
}

- (void)subscribeMemberEvents {
    [self.socket on:kNXMSocketEventMemberJoined callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onMemberJoined:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMemberInvited callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onMemberInvited:data emitter:emitter];
    }];
    
    
    [self.socket on:kNXMSocketEventMemberLeft callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onMemberLeft:data emitter:emitter];
    }];
}

- (void)subscribeTextEvents {
    [self.socket on:kNXMSocketEventText callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onTextRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextSuccess callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
     //   [self onTextRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextDelete callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onTextDeleted:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextSeen callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onTextSeen:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTextDelivered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onTextDelivered:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImage callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onTextRecevied:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImageSeen callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onTextImageSeen:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventImageDelivered callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onTextImageDelivered:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTypingOn callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onTextTypingOn:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventTypingOff callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onTextTypingOff:data emitter:emitter];
    }];
}

- (void)subscribeRTCEvents {
    [self.socket on:kNXMSocketEventRtcAnswer callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onRTCAnswer:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventMemebrMedia callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onRTCMemberMedia:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventAudioMuteOn callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onRTCMuteOn:data emitter:emitter];
    }];
    
    [self.socket on:kNXMSocketEventAudioMuteOff callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        [self onRTCMuteOff:data emitter:emitter];
    }];
}

- (void)subscribeRequestEvents {
    [self.socket on:kNXMConversationCreateDone callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSString *responseId = data[0][@"rid"];
        NSString *conversationId = data[0][@"body"][@"id"];
        if (!responseId || !conversationId) { return; }
        
        if (!self.responseBlockDictionary[responseId]) { return; }
        
        ResponseBlock block = self.responseBlockDictionary[responseId];
        if (block) {
            block(nil, conversationId);
        }
    }];
}


#pragma socket event handle
- (void)onLoginFailed:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    if (!self.isLoggedIn) { return; }
    
    self.isLoggedIn = NO;
    
    [self.delegate userStatusChanged:nil];
}

// member events handle

- (void)onMemberJoined:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [NXMMemberEvent new];
    memberEvent.memberId = json[@"from"];
    memberEvent.user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"user_id"] name:json[@"body"][@"user"][@"name"]];
//    memberEvent.joinDate = json[@"body"][@"timestamp"][@"joined"]; // TODO: NSDate
    memberEvent.sequenceId = json[@"id"];
    memberEvent.state = @"JOINED";
    memberEvent.conversationId = json[@"cid"];
    
    [self.delegate memberJoined:memberEvent];
}

- (void)onMemberInvited:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [NXMMemberEvent new];
    memberEvent.memberId = json[@"from"];
    memberEvent.user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"user_id"] name:json[@"body"][@"user"][@"name"]];
    //    memberEvent.joinDate = json[@"body"][@"timestamp"][@"joined"]; // TODO: NSDate
    memberEvent.sequenceId = json[@"id"];
    memberEvent.state = @"INVITED";
    memberEvent.conversationId = json[@"cid"];
    
    [self.delegate memberInvited:memberEvent];
}

- (void)onMemberLeft:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
    NSDictionary *json = data[0];
    NXMMemberEvent *memberEvent = [NXMMemberEvent new];
    memberEvent.memberId = json[@"from"];
    memberEvent.user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"id"] name:json[@"body"][@"user"][@"name"]];
//    memberEvent.joinDate = json[@"body"][@"timestamp"][@"joined"]; // TODO: NSDate
//    memberEvent.leftDate = json[@"body"][@"timestamp"][@"left"]; // TODO: NSDate
    memberEvent.sequenceId = json[@"id"];
    memberEvent.state = @"LEFT";
    memberEvent.conversationId = json[@"cid"];
    
    [self.delegate memberRemoved:memberEvent];
}

#pragma text event handle

- (void)onTextRecevied:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onTextDeleted:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onTextSeen:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onTextDelivered:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onTextImageSeen:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onTextImageDelivered:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onTextTypingOn:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onTextTypingOff:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

#pragma rtc event handle

- (void)onRTCAnswer:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onRTCMemberMedia:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onRTCMuteOn:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

- (void)onRTCMuteOff:(NSArray *)data emitter:(VPSocketAckEmitter *)emitter {
    
}

#pragma private

- (void)sendRequestWithMSG:(NSString*)event msg:(NSDictionary*)msg requestId:(NSString *)requestId {
    if (!self.isWSOpen) return;

//    NSDictionary * fullMsg = @{  @"body": msg,
//                                 @"tid":requestId
//                                 };
//
//    msg[@"tid"] = requestId;
    
    [self.socket emit:event items:@[msg]];
}


@end
