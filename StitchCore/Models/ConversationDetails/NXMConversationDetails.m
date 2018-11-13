//
//  NXMConversation.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationDetails.h"

@implementation NXMConversationDetails

- (instancetype)initWithId:(NSString *)uuid {
    if (self = [super init]) {
        self.uuid = uuid;
    }
    
    return  self;
}

@end
