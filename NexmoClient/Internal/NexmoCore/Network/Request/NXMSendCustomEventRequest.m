//
//  NXMSendCustomEventRequest.m
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMSendCustomEventRequest.h"

@implementation NXMSendCustomEventRequest

- (nullable instancetype)initWithConversationId:(NSString *)conversationId
                                       memberId:(nonnull NSString *)memberId
                                      customType:(nonnull NSString *)type
                                           body:(nonnull NSString *)body {
    if (self = [super init]) {
        self.conversationId = conversationId;
        self.memberId = memberId;
        self.customType = type;
        self.body = body;
    }
    
    return self;
}

@end
