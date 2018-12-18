//
//  NXMBlocksHelper.m
//  NexmoCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMBlocksHelper.h"

@implementation NXMBlocksHelper

+ (void)runWithError:(nullable NSError *)error completion:(void(^_Nullable)(NSError * _Nullable error))completion {
    if (completion) {
        completion(error);
    }
}

+ (void)runWithError:(nullable NSError *)error
               value:(nullable id)value
          completion:(void(^_Nullable)(NSError * _Nullable error, id _Nullable value))completion {
    if (completion) {
        completion(error, value);
    }
}

@end
