//
//  NXMNSLogger.m
//  StitchTestApp
//
//  Created by Doron Biaz on 8/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMNSLogger.h"
#import "NXMLogger.h"

@implementation NXMNSLogger

- (instancetype)init
{
    self = [super init];
    if (self) {
        [NXMLogger setDelegate:self];
    }
    return self;
}

- (void)debug:(id)message {
    NSLog(@"NXM_DEBUG: %@", message);
}

- (void)error:(id)message {
    NSLog(@"NXM_ERROR: %@", message);
}

- (void)info:(id)message {
    NSLog(@"NXM_INFO: %@", message);
}

- (void)warning:(id)message {
    NSLog(@"NXM_WARNING: %@", message);
}

@end
