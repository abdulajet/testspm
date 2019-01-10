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

- (instancetype)initWithMemberId:(NSString *)memberId
                  conversationId:(NSString *)conversationId
                            user:(NXMUser *)user
                           state:(NXMMemberState)state {
    if (self = [super init]) {
        self.memberId = memberId;
        self.conversationId = conversationId;
        self.user = user;
        self.state = state;
    }
    
    return self;
}

- (instancetype)initWithMemberEvent:(NXMMemberEvent *)memberEvent
{
    self = [super init];
    if (self) {
        self.memberId = memberEvent.memberId;
        self.conversationId = memberEvent.conversationId;
        self.state = memberEvent.state;
        self.user = memberEvent.user;
    }
    return self;
}
@end
