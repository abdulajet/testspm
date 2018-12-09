//
//  NTATokenProvider.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NTATokenProvider.h"

@implementation NTATokenProvider

// TODO: add users...

+ (void)getTokenForUser:(NSString *)user
               password:(NSString *)password
             completion:(void(^_Nullable)(NSError * _Nullable error, NSString *token))completion {
    completion(nil, @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTU0NDM2NzM4NCwibmJmIjoxNTQ0MzY3Mzg0LCJleHAiOjE1NDQzOTc0MTQsImp0aSI6MTU0NDM2NzQxNDU0NSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjcifQ.ZRU5UoDVj424hxUjkwZ7Y4GBjIRgdeIVFuzLFSZqLXScKdclLue8swQfQHyQR4VhwVV3Rix92nRwaBg93tgoq2fPnJidiSnALnDJF92X0b5lrHlyE9j1eMcKT49dE-R75Xu9iA_qfibRyyYq3QsT3tYnOQSKSfZfex-DDlKsJqbc-O_Qz8t8PVwyZqCvHq853hqIYeK0EfJpZYe_U61-lhHUrPL5rI9sJz2VHHpnZzJmpEvVNKPPto_Z8rp0A-nuziuDxf-b2eR520YiK08b_Zs9hN04ZeAyH-RWLS_k9zj7uh-IslCZfGXLRFK1WN12z14A9Ae8puUm_PddXf_yzg");
}

@end
