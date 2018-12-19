//
//  NXMInvitePstnKnockingRequest.m
//  StitchObjC
//
//  Created by Assaf Passal on 7/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMInvitePstnKnockingRequest.h"

@implementation NXMInvitePstnKnockingRequest

- (instancetype)initWithUserName:(nonnull NSString *)userName andPhoneNumber:(nonnull NSString *)phoneNumber{
    if (self = [super init]) {
        self.userName = userName;
        self.phoneNumber = phoneNumber;
    }
    
    return self;
}

@end
