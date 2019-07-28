//
//  NTALoggingUtils.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTALogger : NSObject

+ (void)error:(nonnull NSString *)message;
+ (void)warning:(nonnull NSString *)message;
+ (void)info:(nonnull NSString *)message;
+ (void)debug:(nonnull NSString *)message;

+ (void)errorWithFormat:(nonnull NSString *)format, ...;
+ (void)warningWithFormat:(nonnull NSString *)format, ...;
+ (void)infoWithFormat:(nonnull NSString *)format, ...;
+ (void)debugWithFormat:(nonnull NSString *)format, ...;

+ (nullable NSArray<NSString *> *)getLogs;
@end

