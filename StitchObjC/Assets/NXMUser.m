//
//  User.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/26/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "StitchObjC.h"

@implementation NXMUser

- (instancetype)initWithId:(NSString *)uuid name:(NSString *)name {
    if(self = [super init]) {
        self.uuid = uuid;
        self.name = name;
    }
    
    return self;
}

@end
