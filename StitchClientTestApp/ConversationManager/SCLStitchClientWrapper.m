//
//  KommsClientWrapper.m
//  KommsTestApp
//
//  Created by Doron Biaz on 10/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "SCLStitchClientWrapper.h"
#import <UIKit/UINavigationController.h>

NSString *const kSCLLoginSuccessNotificationKey = @"sclLoginSuccess";
NSString *const kSCLLogoutSuccessNotificationKey = @"sclLogoutSuccess";;
NSString *const kSCLLoginFailureNotificationKey = @"sclLoginFailure";

@interface SCLStitchClientWrapper ()
@property (nonatomic, nonnull, readwrite) NXMStitchClient *kommsClient;
@end

@implementation SCLStitchClientWrapper
-(instancetype)initWithKommsClient:(NXMStitchClient *)kommsClient {
    if(self = [super init]) {
        self.kommsClient = kommsClient;
        self.kommsClient.delegate = self;
    }
    return self;
}



#pragma mark - kommsClientDelegate
- (void)connectionStatusChanged:(BOOL)isOnline {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionStatusChanged" object:nil];
}

- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error {
    if(error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCLLoginFailureNotificationKey object:nil userInfo:@{@"error":error}];
        return;
    }

    if(isLoggedIn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCLLoginSuccessNotificationKey object:nil userInfo:@{@"user":user}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCLLogoutSuccessNotificationKey object:nil userInfo:@{@"user":user}];
    }
}


- (void)incomingCall:(nonnull NXMCall *)call{
    NSLog(@"SCLStitchClientWrapper::incomingCall %@", call.conversation.conversationId);
//    SCLIncomingCallViewController *myViewController=[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:NULL]  instantiateViewControllerWithIdentifier:@"SCLInomingCallViewController"];
//    [myViewController updateWithCall:call];
//    UINavigationController * navigationController = [UINavigationController init];
//    [navigationController showViewController:myViewController sender:nil];
    [call answer:nil completionHandler:^(NSError * _Nullable error) {
        NSLog(@"Error ");
    }];
}

- (void)tokenRefreshed {
    
}

@end
