//
//  NXMMediaSettings.m
//  NexmoCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMediaSettings.h"

@implementation NXMMediaSettings

- (instancetype)initWithEnabled:(BOOL)enabled suspend:(BOOL)suspend {
    if (self = [super init]) {
        self.isEnabled = enabled;
        self.isSuspended = suspend;
    }
    
    return self;
}

- (void)updateWithEnabled:(BOOL)enabled suspend:(BOOL)suspend {
    self.isEnabled = enabled;
    self.isSuspended = suspend;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"isEnabled=%i isSuspended=%i",
            self.isEnabled,
            self.isSuspended];
}
@end
