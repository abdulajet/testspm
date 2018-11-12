//
//  NXMEventsDispatcher.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMStitchCoreDelegate.h"
#import "NXMEventsDispatcherConstants.h"
#import "NXMEventsDispatcherNotificationHelper.h"

@interface NXMEventsDispatcher : NSObject  <NXMStitchCoreDelegate>
@property (readonly, nonatomic) NSNotificationCenter *notificationCenter;
@end
