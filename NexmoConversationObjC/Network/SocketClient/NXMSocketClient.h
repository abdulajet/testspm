//
//  SocketClient.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMSocketClientDelegate.h"

@interface NXMSocketResponse : NSObject
@property NSString * _Nullable eventId;
@property NSObject * _Nullable data;
@end

@interface NXMSocketClient : NSObject

- (nullable instancetype)initWitHost:(nonnull NSString *)host;

- (void)setDelegate:(_Nonnull id<NXMSocketClientDelegate>)delegate;
- (BOOL)isSocketOpen;

- (void)loginWithToken:(NSString * _Nonnull)token;

- (void)logout;

- (void)seenTextEvent:(nonnull NSString *)conversationId
         memberId:(nonnull NSString *)memberId
          eventId:(nonnull NSString *)eventId;


- (void)deliverTextEvent:(nonnull NSString *)conversationId
        memberId:(nonnull NSString *)memberId
        eventId:(nonnull NSString *)eventId;

- (void)textTypingOn:(nonnull NSString *)conversationId
        memberId:(nonnull NSString *)memberId;

- (void)textTypingOff:(nonnull NSString *)conversationId
        memberId:(nonnull NSString *)memberId;

@end
