//
//  NXMBlocksHelper.h
//  NexmoCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXMBlocksHelper : NSObject

+ (void)runWithError:(nullable NSError *)error completion:(void(^_Nullable)(NSError * _Nullable error))completion;

+ (void)runWithError:(nullable NSError *)error
               value:(nullable id)value
          completion:(void(^_Nullable)(NSError * _Nullable error, id _Nullable value))completion;

@end
