//
//  NXMEventsDispatcherConnectionStatusModel.m
//  StitchObjC
//
//  Created by Doron Biaz on 9/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEventsDispatcherConnectionStatusModel.h"

@implementation NXMEventsDispatcherConnectionStatusModel

- (instancetype)initWithStatus:(NXMConnectionStatus)status andReason:(NXMConnectionStatusReason)reason {
    if(self = [super init]) {
        self.status = status;
        self.reason = reason;
    }
    
    return self;
}

@end
