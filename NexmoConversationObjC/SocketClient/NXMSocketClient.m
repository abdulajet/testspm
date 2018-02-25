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

@interface NXMSocketClient()

@property BOOL isOpen;
@property id<NXMSocketClientDelegate> delegate;
@property VPSocketIOClient *socket;

@end

@implementation NXMSocketClient

#pragma Public

- (void)close {

}

- (void)setupWitHost:(NSString *)host {
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
    
    [self registerSocketEvent];
    
    [self.socket connect];
}

- (BOOL)isSocketOpen {
    return self.isOpen;
}


- (BOOL)loginWithToken:(NSString *)token {
    NSDictionary * msg = @{
                            @"token": token,
                            @"device_id": @"453534fdggh45y",
                            @"device_type": @"iphone",
                            };
    
    [self sendRequestWithMSG:kNXMSocketEventLogin msg:msg];
    
    return YES;
}

- (BOOL)getConversationWithId:(NSString*)id {
//    NSDictionary * requestDictionary = @{
//                                         @"type": NXM_CONVERSATION_GET,
//                                         @"id": id,
//                                         @"body": @{}
//                                         };
    
//    NSString *body = [NSString stringWithFormat:@"&data={\"id\":\"%@\",\"body\":\"{}}",id];
//    return [self sendRequestWithMSG:NXM_CONVERSATION_GET body:body];
    return YES;
}

#pragma Private

- (void)registerSocketEvent {
    [self.socket on:kSocketEventConnect callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (self.isOpen) {return;}
        
        self.isOpen = YES;
        
        [self.delegate connectionStatusChanged:true];
        //NSLog(@"!!!!socket connected");
    }];
    
    [self.socket on:kSocketEventDisconnect callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket disconnected");
        
    }];
    
    [self.socket on:kSocketEventError callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket errorrrr");
    }];
    
    // register
    [self.socket on:kNXMSocketEventLoginSuccess callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket login success yay");
    }];
    
    [self.socket on:kNXMSocketEventSessionInvalid callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket login invalid");
    }];
    
    [self.socket on:kNXMSocketEventInvalidToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket token invalid");
    }];
    
    [self.socket on:kNXMSocketEventExpiredToken callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket token expired");
    }];
    
    [self.socket on:kNXMSocketEventBadPermission callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket BadPermission");
    }];
    
    [self.socket on:kNXMSocketEventInvalidEvent callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket invalid event");
    }];
    
    [self.socket on:kNXMSocketEventUserNotFound callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket user not found");
    }];
    
    [self.socket on:kNXMSocketEventError callback:^(NSArray *data, VPSocketAckEmitter *emitter) {
        NSLog(@"!!!!socket event error");
    }];
}

- (BOOL)sendRequestWithMSG:(NSString*)event msg:(NSDictionary*)msg {
    if (!self.isOpen) return NO;
    
    NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    
    NSDictionary * fullMsg = @{  @"body": msg,
                                 @"tid":intervalString
                                 };
    
    [self.socket emit:kNXMSocketEventLogin items:@[fullMsg]];

    return YES;
}


@end
