//
//  NXMLogger.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMLogger.h"
#define NXMDD_LEGACY_MACROS 0 // Logger
#import <ClientInfrastructures/ClientInfrastructures.h>

@interface NXMLogger()

@property NXMLogger *sharedInstance;

@end

@implementation NXMLogger

+ (void)setLogLevel:(NXMLoggerLevel)logLevel {
    nexmoLogLevel_t level;
    
    switch (logLevel) {
        case NXMLoggerLevelNone:
            level = NEXMO_LOG_LEVEL_NONE;
            break;
        case NXMLoggerLevelError:
            level = NEXMO_LOG_LEVEL_ERROR;
            break;
        case NXMLoggerLevelDebug:
            level = NEXMO_LOG_LEVEL_DEBUG;
            break;
        case NXMLoggerLevelInfo:
            level = NEXMO_LOG_LEVEL_INFO;
            break;
        default:
            break;
    }
    
    [NXMLog setLogLevel:level];
}

+ (void)error:(nonnull NSString *)str {
    [NXMLog critical:str];
}

+ (void)errorWithFormat:(nonnull NSString *)fmt, ... NS_FORMAT_FUNCTION(1,2) {
    va_list ap;
    va_start(ap, fmt);
    [NXMLog critical:[[NSString alloc] initWithFormat:fmt arguments:ap]];
    va_end(ap);
}

+ (void)debug:(nonnull NSString *)str {
    [NXMLog debug:str];
}

+ (void)debugWithFormat:(nonnull NSString *)fmt, ... NS_FORMAT_FUNCTION(1,2) {
    va_list ap;
    va_start(ap, fmt);
    [NXMLog debug:[[NSString alloc] initWithFormat:fmt arguments:ap]];
    va_end(ap);}

+ (void)info:(nonnull NSString *)str {
    [NXMLog info:str];
}

+ (void)infoWithFormat:(nonnull NSString *)fmt, ... NS_FORMAT_FUNCTION(1,2) {
    va_list ap;
    va_start(ap, fmt);
    [NXMLog info:[[NSString alloc] initWithFormat:fmt arguments:ap]];
    va_end(ap);
}

+ (nonnull NSMutableArray *)getLogFileNames {
    return [NXMLog getLogFilesPathes];
}

@end
