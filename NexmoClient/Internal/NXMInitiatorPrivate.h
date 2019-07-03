//
//  NXMInitiatorPrivate.h
//  NexmoClient
//
//  Created by Chen Lev on 6/19/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMInitiator.h"
#import "NXMEnums.h"

@interface NXMInitiator (NXMInitiatorPrivate)

- (instancetype)initWithTime:(NSDate *)time andData:(NSDictionary *)data;

- (instancetype)initWithTime:(NSDate *)time andMemberId:(NSString *)memberId;
@end

