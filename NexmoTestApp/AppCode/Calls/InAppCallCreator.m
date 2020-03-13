//
//  CallBuilder.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/19/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "InAppCallCreator.h"
#import "CommunicationsManager.h"
@interface InAppCallCreator ()
@property (nonatomic) NSString* username;
@end

@implementation InAppCallCreator
- (instancetype)initWithUsername:(NSString *)username {
    if(self = [super init]) {
        self.username = username;
    }
    return self;
}
- (void)callWithDelegate:(id<NXMCallDelegate>)delegate completion:(void (^ _Nullable)(NSError * _Nullable, NXMCall * _Nullable))completion { 
 
    [CommunicationsManager.sharedInstance.client call:self.username callHandler:NXMCallHandlerInApp completionHandler:completion];
}

@end
