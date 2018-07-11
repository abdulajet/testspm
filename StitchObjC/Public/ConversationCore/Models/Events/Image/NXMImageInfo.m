//
//  NXMImageInfo.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 6/3/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMImageInfo.h"

@implementation NXMImageInfo

- (nullable instancetype)initWithUuid:(nonnull NSString *)uuid size:(NSInteger)size url:(nonnull NSURL *)url type:(NXMImageType)type {
    if (self = [super init]) {
        self.uuid = uuid;
        self.size = size;
        self.url = url;
        self.type = type;
    }
    
    return self;
}
@end
