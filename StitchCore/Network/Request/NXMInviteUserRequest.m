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

- (instancetype)initWithConversationId:(NSString *)conversationID andUserID:(NSString *)userID {
    return [self initWithConversationId:conversationID andUserID:userID mediaEnabled:false];
}

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationID andUserID:(nonnull NSString *)userID mediaEnabled:(BOOL)mediaEnabled {
    if (self = [super init]) {
        self.conversationID = conversationID;
        self.userID = userID;
        self.mediaEnabled = mediaEnabled;
    }
    
    return self;
}

@end
