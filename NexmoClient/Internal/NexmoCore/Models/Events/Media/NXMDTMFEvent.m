//
//  NXMDTMFEvent.m
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMDTMFEvent.h"

@interface NXMDTMFEvent()

@property (nullable, nonatomic) NSString *digit;
@property (nullable, nonatomic) NSNumber *duration;

@end

@implementation NXMDTMFEvent

- (instancetype)initWithDigit:(NSString *)digit andDuration:(NSNumber *)duration {
    if (self = [super init]) {
        self.digit = digit;
        self.duration = duration;
    }
    
    return self;
}

@end
