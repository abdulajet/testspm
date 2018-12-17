//
//  NXMEventsDispatcherLoginStatusModel.m
//  StitchObjC
//
//  Created by Doron Biaz on 9/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEventsDispatcherLoginStatusModel.h"

@implementation NXMEventsDispatcherLoginStatusModel
-(instancetype)initWithNXMuser:(NXMUser *)user isLoggedIn:(BOOL)isLoggedIn andError:(NSError *)error {
    if (self = [super init]) {
        self.user = user;
        self.isLoggedIn = isLoggedIn;
        self.error = error;
    }
    return self;
}
@end
