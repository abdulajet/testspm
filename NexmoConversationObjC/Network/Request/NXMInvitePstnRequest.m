//
//  NXMInvitePstnRequest.m
//  NexmoConversationObjC
//
//  Created by user on 12/06/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMInvitePstnRequest.h"

@implementation NXMInvitePstnRequest

- (instancetype)initWithConversationId:(nonnull NSString *)conversationID andUserID:(nonnull NSString *)userID andPhoneNumber:(nonnull NSString *)phoneNumber{
    if (self = [super init]) {
        self.conversationID = conversationID;
        self.userID = userID;
        self.phoneNumber = phoneNumber;
    }
    
    return self;
}

@end

