//
//  NTALoggingUtils.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <StitchClient/StitchClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTALogger : NSObject<NXMLoggerDelegate>

+ (void)error:(nonnull NSString *)message;
+ (void)warning:(nonnull NSString *)message;
+ (void)info:(nonnull NSString *)message;
+ (void)debug:(nonnull NSString *)message;

+ (void)errorWithFormat:(nonnull NSString *)format, ...;
+ (void)warningWithFormat:(nonnull NSString *)format, ...;
+ (void)infoWithFormat:(nonnull NSString *)format, ...;
+ (void)debugWithFormat:(nonnull NSString *)format, ...;
@end

NS_ASSUME_NONNULL_END
