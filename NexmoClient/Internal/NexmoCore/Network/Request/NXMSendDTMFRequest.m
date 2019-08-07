//
//  NXMSendDTMFRequest.m
//  NexmoClient
//
//  Created by Assaf Passal on 8/7/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMSendDTMFRequest.h"

@implementation NXMSendDTMFRequest

- (nullable instancetype)initWithConversationId:(NSString *)conversationId
                                       memberId:(nonnull NSString *)memberId
                                           digit:(nonnull NSString *)digit {
    if (self = [super init]) {
        self.conversationId = conversationId;
        self.memberId = memberId;
        self.digit = digit;
    }
    
    return self;
}

@end
