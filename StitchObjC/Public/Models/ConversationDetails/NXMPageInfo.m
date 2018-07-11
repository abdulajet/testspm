//
//  NXMPageInfo.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMPageInfo.h"

@implementation NXMPageInfo

- (instancetype)initWithCount:(NSNumber *)count pageSize:(NSNumber *)pageSize recordIndex:(NSNumber *)recordIndex {
    if (self = [super init]) {
        self.pageSize = pageSize;
        self.count = count;
        self.recordIndex = recordIndex;
    }
    
    return self;
}

@end

