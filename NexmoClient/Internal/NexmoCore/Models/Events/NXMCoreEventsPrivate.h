//
//  NXMEventPrivate.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMCoreEvents.h"
#import "NXMMemberEventPrivate.h"
#import "NXMLegStatusEventPrivate.h"
#import "NXMCustomEventInternal.h"
#import "NXMEventInternal.h"

@interface NXMDTMFEvent (NXMDTMFEventPrivate)

- (instancetype)initWithDigit:(NSString *)digits andDuration:(NSNumber *)duration;

@end
