//
//  NXMMember.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMember.h"
#import "NXMMemberEvent.h"
@implementation NXMMember

- (instancetype)initWithMemberId:(NSString *)memberId conversationId:(NSString *)conversationId
                            user:(NSString *)userId name:(NSString *)name state:(NXMMemberState)state {
    if (self = [super init]) {
        self.memberId = memberId;
        self.conversationId = conversationId;
        self.userId = userId;
        self.name = name;
        self.state = state;
    }
    
    return self;
}

- (instancetype)initWithMemberEvent:(NXMMemberEvent *)memberEvent
{
    self = [super init];
    if (self) {
        self.memberId = memberEvent.memberId;
        self.name = memberEvent.name;
        self.conversationId = memberEvent.conversationId;
        self.state = memberEvent.state;
        self.userId = memberEvent.user.userId;
    }
    return self;
}
@end
