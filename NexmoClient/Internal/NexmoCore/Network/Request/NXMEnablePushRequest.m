//
//  NXMEnablePushRequest.m
//  StitchObjC
//
//  Created by Chen Lev on 7/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEnablePushRequest.h"

@implementation NXMEnablePushRequest

- (nullable instancetype)initWithPushKitToken:(nullable NSData *)pushKitToken
                        userNotificationToken:(nullable NSData *)userNotificationToken
                                    isSandbox:(BOOL)isSandbox {
    if (self = [super init]) {
        self.pushKitToken = pushKitToken;
        self.isSandbox = isSandbox;
        self.userNotificationToken = userNotificationToken;
    }
    
    return self;
}

@end

