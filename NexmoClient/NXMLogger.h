//
//  NXMLogger.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXMLoggerLevel) {
    NXMLoggerLevelNone,
    NXMLoggerLevelError,
    NXMLoggerLevelDebug,
    NXMLoggerLevelInfo
};

@interface NXMLogger : NSObject
+ (void)setLogLevel:(NXMLoggerLevel)logLevel;

+ (void)error:(nonnull NSString *)str;
+ (void)errorWithFormat:(nonnull NSString *)fmt, ... NS_FORMAT_FUNCTION(1,2);

+ (void)debug:(nonnull NSString *)str;
+ (void)debugWithFormat:(nonnull NSString *)fmt, ... NS_FORMAT_FUNCTION(1,2);

+ (void)info:(nonnull NSString *)str;
+ (void)infoWithFormat:(nonnull NSString *)fmt, ... NS_FORMAT_FUNCTION(1,2);

/**
 @brief get the log files name, while using NXMLogger
 @return NSMutableArray<NSString*>>
 @code NSMutableArray<NSString*>> filesPathes = [NXMLogger getLogFileNames];
 */
+ (nonnull NSMutableArray *)getLogFileNames;

@end
