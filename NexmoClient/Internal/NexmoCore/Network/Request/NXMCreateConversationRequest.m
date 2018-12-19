//
//  NXMCreateConversationRequest.m
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMCreateConversationRequest.h"

@implementation NXMCreateConversationRequest

- (nullable instancetype)initWithDisplayName:(nonnull NSString *)displayName {
    if (self = [super init]) {
        self.displayName = displayName;
    }
    
    return self;
}
@end
