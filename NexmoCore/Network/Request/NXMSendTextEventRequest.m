//
//  NXMSendTextEventRequest.m
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMSendTextEventRequest.h"

@implementation NXMSendTextEventRequest

- (instancetype)initWithText:(NSString *)text conversationId:(NSString*)conversationId memberId:(NSString *)memberId {
    if (self = [super init]) {
        self.textToSend = text;
        self.conversationID = conversationId;
        self.memberID = memberId;
    }
    
    return self;
}
@end
