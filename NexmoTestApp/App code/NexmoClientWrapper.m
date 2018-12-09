//
//  NexmoClientWrapper.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//


#import "NexmoClientWrapper.h"


@interface NexmoClientWrapper()
@property (nonatomic, nonnull, readwrite) NXMStitchClient *client;
@end

@implementation NexmoClientWrapper

+ (nonnull NexmoClientWrapper *)sharedInstance {
    
    static NexmoClientWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NexmoClientWrapper alloc] init];
        sharedInstance.client = [[NXMStitchClient alloc] init];
        [sharedInstance.client setDelegate:sharedInstance];
    });
    
    return sharedInstance;
}

#pragma mark - kommsClientDelegate
- (void)connectionStatusChanged:(BOOL)isOnline {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionStatusChanged" object:nil];
}

- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error {
    if(error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailure" object:nil userInfo:@{@"error":error}];
        return;
    }
    
    if(isLoggedIn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil userInfo:@{@"user":user}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil userInfo:@{@"user":user}];
    }
}

- (void)tokenRefreshed {
    
}


@end

