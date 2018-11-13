//
//  NXMDeleteEventRequest.m
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMDeleteEventRequest.h"

@implementation NXMDeleteEventRequest

- (instancetype)initWithEventId:(NSInteger)eventId conversationId:(nonnull NSString*)conversationId memberId:(nonnull NSString *)memberId {
    if (self = [super init]){
        self.eventID = eventId;
        self.conversationID = conversationId;
        self.memberID = memberId;
    }
    
    return self;
}
@end
