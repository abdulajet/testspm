//
//  NXMEventsDispatcher.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMEventsDispatcherConstants.h"
#import "NXMEventsDispatcherNotificationHelper.h"
#import "NXMCoreDelegate.h"

@interface NXMEventsDispatcher : NSObject<NXMCoreDelegate>
@property (readonly, nonatomic) NSNotificationCenter *notificationCenter;
@end
