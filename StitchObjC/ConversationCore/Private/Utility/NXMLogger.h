//
//  NXMLogger.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMLoggerDelegate.h"
@interface NXMLogger : NSObject

+ (void)setDelegate:(nonnull id<NXMLoggerDelegate>)delegate;

+ (void)error:(nonnull NSString *)message;
+ (void)warning:(nonnull NSString *)message;
+ (void)info:(nonnull NSString *)message;
+ (void)debug:(nonnull NSString *)message;

+ (void)errorWithFormat:(nonnull NSString *)format, ...;
+ (void)warningWithFormat:(nonnull NSString *)format, ...;
+ (void)infoWithFormat:(nonnull NSString *)format, ...;
+ (void)debugWithFormat:(nonnull NSString *)format, ...;

@end
