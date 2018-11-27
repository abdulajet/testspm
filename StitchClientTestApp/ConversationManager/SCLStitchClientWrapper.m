//
//  KommsClientWrapper.m
//  KommsTestApp
//
//  Created by Doron Biaz on 10/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "SCLStitchClientWrapper.h"

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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailure" object:nil userInfo:@{@"error":error}];
        return;
    }

    if(isLoggedIn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil userInfo:@{@"user":user}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil userInfo:@{@"user":user}];
    }
}

@end
