//
//  NXMMember.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMember.h"

@implementation NXMMember

- (instancetype)initWithMemberId:(NSString *)memberId conversationId:(NSString *)conversationId joinDate:(NSDate *)joinDate
                          user:(NXMUser *)user name:(NSString *)name state:(NSString *)state {
    if (self = [super init]) {
        self.memberId = memberId;
        self.conversationId = conversationId;
        self.joinDate = joinDate;
        self.user = user;
        self.name = name;
        self.state = state;
    }
    
    return self;
}
@end
