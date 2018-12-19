//
//  NXMMediaSuspendEvent.h
//  NexmoCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMediaActionEvent.h"

@interface NXMMediaSuspendEvent : NXMMediaActionEvent
@property (nonatomic) bool isSuspended;
@end
