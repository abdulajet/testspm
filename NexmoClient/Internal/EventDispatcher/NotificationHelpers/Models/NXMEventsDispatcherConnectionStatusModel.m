//
//  NXMEventsDispatcherConnectionStatusModel.m
//  StitchObjC
//
//  Created by Doron Biaz on 9/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEventsDispatcherConnectionStatusModel.h"

@implementation NXMEventsDispatcherConnectionStatusModel
-(instancetype)initWithIsConnected:(BOOL)isConnected {
    if(self = [super init]) {
        self.isConnected = isConnected;
    }
    return self;
}
@end
