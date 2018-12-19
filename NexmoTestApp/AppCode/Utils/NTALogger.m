//
//  NTALoggingUtils.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NTALogger.h"

static NSString * const kNTALogPrefix = @"NTALog ";
static NSString * const kNTALogErrorPrefix = @"NTALog [Error]: ";
static NSString * const kNTALogWarningPrefix = @"NTALog [Warning]: ";
static NSString * const kNTALogInfoPrefix = @"NTALog [Info]: ";
static NSString * const kNTALogDebugPrefix = @"NTALog [Debug]: ";


@interface NTALogger ()
- (void)error:(nonnull NSString *)message;
- (void)warning:(nonnull NSString *)message;
- (void)info:(nonnull NSString *)message;
- (void)debug:(nonnull NSString *)message;
@end


@implementation NTALogger

+(NTALogger *)sharedLogger {
    static NTALogger *sharedLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [NTALogger new];
    });
    
    return sharedLogger;
}

- (void)error:(nonnull NSString *)message {
    NSLog(@"%@ %@", kNTALogErrorPrefix, message);
}

- (void)warning:(nonnull NSString *)message {
    NSLog(@"%@ %@", kNTALogWarningPrefix, message);
}

- (void)info:(nonnull NSString *)message {
    NSLog(@"%@ %@", kNTALogInfoPrefix, message);
}

- (void)debug:(nonnull NSString *)message {
    NSLog(@"%@ %@", kNTALogDebugPrefix, message);
}

#pragma mark - Class Methods

+ (void)error:(nonnull NSString *)message {
    [[self sharedLogger] error:message];
}

+ (void)warning:(nonnull NSString *)message {
    [[self sharedLogger] warning:message];
}

+ (void)info:(nonnull NSString *)message {
    [[self sharedLogger] info:message];
}

+ (void)debug:(nonnull NSString *)message {
    [[self sharedLogger] debug:message];
}



+ (void)errorWithFormat:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    [self error:[[NSString alloc] initWithFormat:format arguments:ap]];
    va_end(ap);
}

+ (void)warningWithFormat:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    [self warning:[[NSString alloc] initWithFormat:format arguments:ap]];
    va_end(ap);
}

+ (void)infoWithFormat:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    [self info:[[NSString alloc] initWithFormat:format arguments:ap]];
    va_end(ap);
}

+ (void)debugWithFormat:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    [self debug:[[NSString alloc] initWithFormat:format arguments:ap]];
    va_end(ap);
}
@end
