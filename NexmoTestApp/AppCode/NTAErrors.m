//
//  NXMTestAppErrors.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NTAErrors.h"
NSString * const NXMTestAppErrorDomain = @"com.nexmo.TestAppErrorDomain";

@implementation NTAErrors
+(NSError *)errorWithErrorCode:(NXMTestAppErrorCode)errorCode andUserInfo:(nullable NSDictionary<NSErrorUserInfoKey,id> *)userInfo {
    return [NSError errorWithDomain:NXMTestAppErrorDomain code:errorCode userInfo:userInfo];
}
@end
