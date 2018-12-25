//
//  CallBuilder.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/19/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ServerCallCreator.h"
#import "CommunicationsManager.h"
#import "NTAUserInfo.h"

@interface ServerCallCreator ()
@property (nonatomic) NSArray<NTAUserInfo *> *users;
@end

@implementation ServerCallCreator

- (instancetype)initWithUsers:(NSArray<NTAUserInfo *> *)users {
    if(self = [super init]) {
        self.users = users;
    }
    return self;
}

- (void)callWithDelegate:(id<NXMCallDelegate>)delegate completion:(void (^ _Nullable)(NSError * _Nullable, NXMCall * _Nullable))completion {
    NSMutableArray <NSString *> *csUserNames = [NSMutableArray new];
    for (NTAUserInfo *userInfo in self.users) {
        [csUserNames addObject: [userInfo.csUserName copy]];
    }
    [CommunicationsManager.sharedInstance.client callToUsers:csUserNames callType:NXMCallTypeServer delegate:delegate completion:completion];
}

@end
