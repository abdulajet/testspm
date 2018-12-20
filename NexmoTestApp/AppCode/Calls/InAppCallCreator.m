//
//  CallBuilder.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/19/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "InAppCallCreator.h"
#import "CommunicationsManager.h"
#import "NTAUserInfo.h"

@interface InAppCallCreator ()
@property (nonatomic) NSArray<NTAUserInfo *> *users;
@end

@implementation InAppCallCreator
- (instancetype)initWithUsers:(NSArray<NTAUserInfo *> *)users {
    if(self = [super init]) {
        self.users = users;
    }
    return self;
}
- (void)callWithDelegate:(id<NXMCallDelegate>)delegate completion:(void (^ _Nullable)(NSError * _Nullable, NXMCall * _Nullable))completion { 
    NSMutableArray <NSString *> *csUserNames = [NSMutableArray new];
    for (NTAUserInfo *userInfo in self.users) {
        [csUserNames addObject: [userInfo.csUserId copy]];
    }
    [CommunicationsManager.sharedInstance.client callToUsers:csUserNames delegate:delegate completion:completion];
}

@end
