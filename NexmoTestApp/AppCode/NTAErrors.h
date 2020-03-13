//
//  NXMTestAppErrors.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * _Nonnull const NXMTestAppErrorDomain;

typedef NS_ENUM(NSInteger, NXMTestAppErrorCode) {
    NXMTestAppErrorCodeNone,
    
    NXMTestAppErrorCodeUnknown,
    NXMTestAppErrorCodeTestAppUserNotFound,
    NXMTestAppErrorCodeTestAppCurrentUserNotFound,
    NXMTestAppErrorCodeFailedEnablingPush,
    NXMTestAppErrorCodeFailedDisablingPush
    
    
    
};

@interface NTAErrors : NSObject
+(NSError *)errorWithErrorCode:(NXMTestAppErrorCode)errorCode andUserInfo:(nullable NSDictionary<NSErrorUserInfoKey,id> *)userInfo;
@end

NS_ASSUME_NONNULL_END
