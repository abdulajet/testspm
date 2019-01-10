//
//  NXMErrors.m
//  NexmoCore
//
//  Created by Chen Lev on 3/22/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMErrorsPrivate.h"

NSString *const NXMErrorDomain = @"com.nexmo.errorDomain";

@implementation NXMErrors
+(NSError *)nxmErrorWithErrorCode:(NXMErrorCode)errorCode andUserInfo:(nullable NSDictionary<NSErrorUserInfoKey,id> *)userInfo {
    return [NSError errorWithDomain:NXMErrorDomain code:errorCode userInfo:userInfo];
}
@end

