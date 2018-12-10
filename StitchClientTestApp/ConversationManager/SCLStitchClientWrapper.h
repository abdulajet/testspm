//
//  KommsClientWrapper.h
//  KommsTestApp
//
//  Created by Doron Biaz on 10/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StitchClient/StitchClient.h>

FOUNDATION_EXPORT NSString *const kSCLLoginSuccessNotificationKey;
FOUNDATION_EXPORT NSString *const kSCLLogoutSuccessNotificationKey;
FOUNDATION_EXPORT NSString *const kSCLLoginFailureNotificationKey;

@class NXMStitchClient;

@interface SCLStitchClientWrapper : NSObject <NXMStitchClientDelegate>
@property (nonatomic, nonnull, readonly) NXMStitchClient *kommsClient;

-(instancetype)initWithKommsClient:(nonnull NXMStitchClient *)kommsClient;
@end
