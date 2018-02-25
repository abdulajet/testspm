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
@property NSString *eventId;
@property NSObject *data;
@end

@interface NXMSocketClient : NSObject

- (nullable instancetype)initWitHost:(nonnull NSString *)host;

- (void)setDelegate:(id<NXMSocketClientDelegate>)delegate;
- (BOOL)isSocketOpen;

- (void)loginWithToken:(NSString *)token;

- (void)sendText:(nonnull NSString *)text
  conversationId:(nonnull NSString *)conversationId
    fromMemberId:(nonnull NSString *)fromMemberId
 completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMSocketResponse * _Nullable response))completionBlock;

@end
