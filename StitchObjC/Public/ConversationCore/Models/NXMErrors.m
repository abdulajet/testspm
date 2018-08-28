//
//  NXMErrors.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/22/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMErrors.h"

NSString *const NXMStitchErrorDomain = @"com.nexmo.StitchErrorDomain";

@implementation NXMErrors
+(NSError *)nxmStitchErrorWithErrorCode:(NXMStitchErrorCode)errorCode andUserInfo:(nullable NSDictionary<NSErrorUserInfoKey,id> *)userInfo {
    return [NSError errorWithDomain:NXMStitchErrorDomain code:errorCode userInfo:userInfo];
}
@end

