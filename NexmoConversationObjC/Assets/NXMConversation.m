//
//  NXMConversation.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversation.h"

@implementation NXMConversation

- (instancetype)initWithId:(NSString *)uuid href:(NSString *)href {
    if (self = [super init]) {
        self.uuid = uuid;
        self.href = href;
    }
    
    return  self;
}

@end
