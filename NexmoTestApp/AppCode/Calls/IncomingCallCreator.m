//
//  IncomingCallCreator.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/20/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "IncomingCallCreator.h"

@interface IncomingCallCreator()
@property NXMCall *call;
@end

@implementation IncomingCallCreator

- (instancetype)initWithCall:(NXMCall *)call {
    if (self = [super init]) {
        self.call = call;
    }
    
    return self;
}

- (void)callWithDelegate:(id<NXMCallDelegate>)delegate completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion {
    [self.call setDelegate:delegate];
    completion(nil, self.call);
}

@end
