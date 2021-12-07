//
//  NXMLogger.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A list of the log levels.
 */
typedef NS_ENUM(NSInteger, NXMLoggerLevel) {
    /// No log statements.
    NXMLoggerLevelNone,
    /// Log error statements.
    NXMLoggerLevelError,
    /// Log debug and error statements.
    NXMLoggerLevelDebug,
    /// Log debug, warn and error statements.
    NXMLoggerLevelInfo,
    /// All available log statements.
    NXMLoggerLevelVerbose
};

/**
 * A class used to configure the logging settings of the SDK.
 */
@interface NXMLogger : NSObject
/**
 Set the `NXMLogger` log level.
 @param logLevel The desire `NXMLoggerLevel` case.
 */
+ (void)setLogLevel:(NXMLoggerLevel)logLevel;

/**
 Get the log files name, while using NXMLogger.
 @return NSMutableArray<NSString*>>
 @code NSMutableArray<NSString*>> filesPathes = [NXMLogger getLogFileNames];
 */
+ (nonnull NSMutableArray *)getLogFileNames;

@end
