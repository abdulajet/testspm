//
//  NXMAddUserRequest.m
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMAddUserRequest.h"

@implementation NXMAddUserRequest

- (instancetype)initWithConversationId:(NSString *)conversationID andUserID:(NSString *)userID {
    if (self = [super init]) {
        self.conversationID = conversationID;
        self.userID = userID;
    }
    
    return self;
}
@end
