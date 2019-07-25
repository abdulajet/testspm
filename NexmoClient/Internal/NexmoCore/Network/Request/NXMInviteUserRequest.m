//
//  NXMInviteUserRequest.m
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMInviteUserRequest.h"

@implementation NXMInviteUserRequest

- (instancetype)initWithConversationId:(NSString *)conversationID username:(NSString *)username {
    return [self initWithConversationId:conversationID username:username mediaEnabled:false];
}

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationID username:(nonnull NSString *)username mediaEnabled:(BOOL)mediaEnabled {
    if (self = [super init]) {
        self.conversationID = conversationID;
        self.username = username;
        self.mediaEnabled = mediaEnabled;
    }
    
    return self;
}

@end
