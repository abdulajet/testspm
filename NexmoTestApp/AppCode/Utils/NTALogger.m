//
//  NTALoggingUtils.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NTALogger.h"
#import <NexmoClient/NexmoClient.h>

@implementation NTALogger

+ (void)error:(nonnull NSString *)message {
    [NXMLogger errorWithFormat:@"TestApp %@", message];
}

+ (void)warning:(nonnull NSString *)message {
    [NXMLogger errorWithFormat:@"TestApp %@", message];
}

+ (void)info:(nonnull NSString *)message {
    [NXMLogger infoWithFormat:@"TestApp %@", message];
}

+ (void)debug:(nonnull NSString *)message {
    [NXMLogger debugWithFormat:@"TestApp %@", message];
}


+ (void)errorWithFormat:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    [NTALogger error:[[NSString alloc] initWithFormat:format arguments:ap]];
    va_end(ap);
}

+ (void)warningWithFormat:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    [NTALogger warning:[[NSString alloc] initWithFormat:format arguments:ap]];
    va_end(ap);
}

+ (void)infoWithFormat:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    [NTALogger info:[[NSString alloc] initWithFormat:format arguments:ap]];
    va_end(ap);
}

+ (void)debugWithFormat:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    [NTALogger debug:[[NSString alloc] initWithFormat:format arguments:ap]];
    va_end(ap);
}

#pragma mark - GetLog

+ (NSArray<NSString *> *)getLogs {
    return [NXMLogger getLogFileNames];
}

@end
