//
//  NXMEnablePushRequest.m
//  StitchObjC
//
//  Created by Chen Lev on 7/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEnablePushRequest.h"

@implementation NXMEnablePushRequest

- (nullable instancetype)initWithDeviceToken:(nonnull NSData *)deviceToken {
    if (self = [super init]) {
        self.deviceToken = deviceToken;
    }
    
    return self;
}

@end

