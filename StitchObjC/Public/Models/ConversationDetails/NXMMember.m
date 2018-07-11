//
//  NXMMember.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMember.h"

@implementation NXMMember

- (instancetype)initWithMemberId:(NSString *)memberId conversationId:(NSString *)conversationId
                            user:(NSString *)userId name:(NSString *)name state:(NSString *)state {
    if (self = [super init]) {
        self.memberId = memberId;
        self.conversationId = conversationId;
        self.userId = userId;
        self.name = name;
        self.state = state;
    }
    
    return self;
}
@end
