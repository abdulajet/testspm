//
//  PSTNCallCreator.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "PSTNCallCreator.h"
#import "CommunicationsManager.h"

@interface PSTNCallCreator()
@property NXMCall *call;
@property NSString *number;
@end

@implementation PSTNCallCreator

- (instancetype)initWithNumber:(NSString *)number {
    if (self = [super init]) {
        self.number = number;
    }
    
    return self;
}

- (void)callWithDelegate:(id<NXMCallDelegate>)delegate
              completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion {

    [CommunicationsManager.sharedInstance.client call:self.number
                                          callHandler:NXMCallHandlerServer
                                    completionHandler:completion];
}
@end
