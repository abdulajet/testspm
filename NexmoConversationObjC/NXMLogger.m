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

static NXMLogger *sharedInstance = nil;

+ (NXMLogger *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [NXMLogger new];
    }
    
    return sharedInstance;
}

+ (void)setDelegate:(nonnull id<NXMLoggerDelegate>)delegate {
    self.delegate = delegate;
}

+ (void)error:(nullable NSString *)message {
    [self.sharedInstance.delegate error:message];
}

+ (void)warning:(nullable NSString *)message {
    [self.sharedInstance.delegate warning:message];
}

+ (void)info:(nullable NSString *)message {
    [self.sharedInstance.delegate info:message];
}

+ (void)debug:(nullable NSString *)message {
    [self.sharedInstance.delegate debug:message];
}

@end
