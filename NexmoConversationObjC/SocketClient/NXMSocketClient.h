//
//  SocketClient.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMSocketClientDelegate.h"

@interface NXMSocketClient : NSObject

- (void)setupWitHost:(NSString *)host;

- (void)setDelegate:(id<NXMSocketClientDelegate>)delegate;
- (BOOL)isSocketOpen;

- (BOOL)loginWithToken:(NSString *)token;

- (BOOL)getConversationWithId:(NSString*)id;

@end
