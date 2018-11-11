//
//  NXMLogger.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMLogger.h"

@interface NXMLogger()

@property id<NXMLoggerDelegate> delegate;
@property NXMLogger *sharedInstance;

@end

@implementation NXMLogger

+ (NXMLogger *)sharedInstance {
    static NXMLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [NXMLogger new];
    });
    
    return sharedInstance;
}

+ (void)setDelegate:(nonnull id<NXMLoggerDelegate>)delegate {
    [self sharedInstance].delegate = delegate;
}

+ (void)error:(nonnull NSString *)message {
    [[self sharedInstance].delegate error:message];
}

+ (void)warning:(nonnull NSString *)message {
    [[self sharedInstance].delegate warning:message];
}

+ (void)info:(nonnull NSString *)message {
    [[self sharedInstance].delegate info:message];
}

+ (void)debug:(nonnull NSString *)message {
    [[self sharedInstance].delegate debug:message];
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
