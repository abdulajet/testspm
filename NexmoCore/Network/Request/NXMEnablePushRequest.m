//
//  NXMEnablePushRequest.m
//  StitchObjC
//
//  Created by Chen Lev on 7/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEnablePushRequest.h"

@implementation NXMEnablePushRequest

- (nullable instancetype)initWithDeviceToken:(nonnull NSData *)deviceToken isSandbox:(BOOL)isSandbox {
    if (self = [super init]) {
        self.deviceToken = deviceToken;
        self.isSandbox = isSandbox;
    }
    
    return self;
}

@end

