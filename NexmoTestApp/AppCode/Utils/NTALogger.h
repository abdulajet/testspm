//
//  NTALoggingUtils.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <NexmoClient/NexmoClient.h>

@interface NTALogger : NSObject<NXMLoggerDelegate>

+ (nonnull instancetype)sharedLogger;

+ (void)error:(nonnull NSString *)message;
+ (void)warning:(nonnull NSString *)message;
+ (void)info:(nonnull NSString *)message;
+ (void)debug:(nonnull NSString *)message;

+ (void)errorWithFormat:(nonnull NSString *)format, ...;
+ (void)warningWithFormat:(nonnull NSString *)format, ...;
+ (void)infoWithFormat:(nonnull NSString *)format, ...;
+ (void)debugWithFormat:(nonnull NSString *)format, ...;

+ (NSString * _Nullable)getLog;
@end

