//
//  NXMSocketClient.h
//  StitchObjC
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMSocketClientDelegate.h"

@interface NXMSocketResponse : NSObject
@property NSString * _Nullable eventId;
@property NSObject * _Nullable data;
@end

@interface NXMSocketClient : NSObject

- (nullable instancetype)initWithHost:(nonnull NSString *)host;

- (void)setDelegate:(_Nonnull id<NXMSocketClientDelegate>)delegate;
- (BOOL)isSocketOpen;
- (void)loginWithToken:(nonnull NSString *)token;
- (void)logout;

#pragma conversation actions

- (void)seenTextEvent:(nonnull NSString *)conversationId
         memberId:(nonnull NSString *)memberId
          eventId:(NSInteger)eventId;


- (void)deliverTextEvent:(nonnull NSString *)conversationId
        memberId:(nonnull NSString *)memberId
        eventId:(NSInteger)eventId;

- (void)textTypingOn:(nonnull NSString *)conversationId
        memberId:(nonnull NSString *)memberId;

- (void)textTypingOff:(nonnull NSString *)conversationId
        memberId:(nonnull NSString *)memberId;

@end
