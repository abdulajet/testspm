//
//  CallBuilder.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/19/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ServerCallCreator.h"
#import "CommunicationsManager.h"

@interface ServerCallCreator ()
@property (nonatomic) NSString *username;
@end

@implementation ServerCallCreator

- (instancetype)initWithUsername:(NSString *)username {
    if(self = [super init]) {
        self.username = username;
    }
    return self;
}

- (void)callWithDelegate:(id<NXMCallDelegate>)delegate completion:(void (^ _Nullable)(NSError * _Nullable, NXMCall * _Nullable))completion {
  
    [CommunicationsManager.sharedInstance.client call:_username callHandler:NXMCallHandlerServer completionHandler:completion];
}

@end
