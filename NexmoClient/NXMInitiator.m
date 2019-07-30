//
//  NXMInitiator.m
//  NexmoClient
//
//  Created by Chen Lev on 6/19/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMInitiator.h"

@interface NXMInitiator()
@property (nonatomic, assign) BOOL isSystem;

@end

@implementation NXMInitiator

- (instancetype)initWithTime:(NSDate *)time andData:(NSDictionary *)data {
    return [self initWithtime:time memberId:data[@"member_id"] userId:data[@"user_id"] isSystem:[data[@"isSystem"] boolValue]];
}

- (instancetype)initWithtime:(NSDate *)time
                    memberId:(NSString *)memberId
                      userId:(NSString *)userId
                    isSystem:(BOOL)isSystem {
    if (self = [super init]) {
        self.time = time;
        self.memberId = memberId;
        self.userId = userId;
        self.isSystem = isSystem;
    }
    
    return self;
}

- (instancetype)initWithTime:(NSDate *)time andMemberId:(NSString *)memberId {
    return [self initWithtime:time memberId:memberId userId:nil isSystem:memberId ? NO : YES];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> isSystem=%i memberId=%@ userId=%@ time=%@",
            NSStringFromClass([self class]),
            self,
            self.isSystem,
            self.memberId,
            self.userId,
            self.time];
}



@end
