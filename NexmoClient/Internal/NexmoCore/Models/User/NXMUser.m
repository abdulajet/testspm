//
//  User.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/26/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMUser.h"

@implementation NXMUser
- (instancetype)initWithId:(NSString *)uuid name:(NSString *)name {
    return [self initWithId:uuid name:name displayName:nil];
}

- (instancetype)initWithId:(NSString *)uuid name:(NSString *)name displayName:(NSString * _Nullable)displayName{
    if(self = [super init]) {
        self.userId = uuid;
        self.name = name;
        self.displayName = displayName;
    }
    
    return self;
}

@end
