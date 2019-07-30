//
//  User.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/26/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMUser.h"

@implementation NXMUser

- (instancetype)initWithId:(NSString *)uuid name:(NSString *)name displayName:(NSString * _Nullable)displayName{
    if(self = [super init]) {
        self.userId = uuid;
        self.name = name;
        self.displayName = displayName;
    }
    
    return self;
}

- (nullable instancetype)initWithData:(nonnull NSDictionary *)data {
    NSString *userId = data[@"user_id"] ? data[@"user_id"] : data[@"id"];
    
    return [self initWithId:userId name:data[@"name"] displayName:data[@"display_name"]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> displayName=%@ name=%@ userId=%@",
            NSStringFromClass([self class]),
            self,
            self.displayName,
            self.name,
            self.userId];
}



@end
