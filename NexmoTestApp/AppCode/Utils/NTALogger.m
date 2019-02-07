//
//  NTALoggingUtils.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NTALogger.h"

static NSString * const kNTALogErrorPrefix = @"NTALog [Error]: ";
static NSString * const kNTALogWarningPrefix = @"NTALog [Warning]: ";
static NSString * const kNTALogInfoPrefix = @"NTALog [Info]: ";
static NSString * const kNTALogDebugPrefix = @"NTALog [Debug]: ";


@interface NTALogger ()
@property NSMutableArray<NSString *> *savedLogs;
@property NSOperationQueue *opQueue;
@end


@implementation NTALogger

- (instancetype)init {
    if(self = [super init]) {
        self.savedLogs = [NSMutableArray new];
        self.opQueue = [NSOperationQueue new];
        self.opQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

+(nonnull instancetype)sharedLogger {
    static NTALogger *sharedLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [NTALogger new];
    });
    
    return sharedLogger;
}

- (void)error:(nullable NSString *)message {
    [self logWithPrefix:kNTALogErrorPrefix andMessage:message];
}

- (void)warning:(nullable NSString *)message {
    [self logWithPrefix:kNTALogWarningPrefix andMessage:message];
}

- (void)info:(nullable NSString *)message {
    [self logWithPrefix:kNTALogInfoPrefix andMessage:message];
}

- (void)debug:(nullable NSString *)message {
    [self logWithPrefix:kNTALogDebugPrefix andMessage:message];
}

- (void)logWithPrefix:(NSString *)prefix andMessage:(nullable NSString *)message {
    NSString *prefixedMessage = [prefix stringByAppendingString:message];
    [self logWithMessage:prefixedMessage];
}

- (void)logWithMessage:(nullable NSString *)message {
    NSDate *currDate = [NSDate date];
    NSString *timedMessage = [NSString stringWithFormat:@"%@  %@", currDate, message];
    [self.opQueue addOperationWithBlock:^{
        NSLog(@"%@", timedMessage);
        [self.savedLogs addObject:timedMessage];
    }];
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

#pragma mark - GetLog

+ (void)getLogWithCompletion:(void (^ _Nullable)(NSString * _Nullable log))completion {
    [[self sharedLogger] getLogWithCompletion:completion];
    
}

- (void)getLogWithCompletion:(void (^ _Nullable)(NSString * _Nullable log))completion {
    [self.opQueue addOperationWithBlock:^{
        if(completion) {
            completion([self.savedLogs componentsJoinedByString:@"\n"]);
        }
    }];
}
@end
