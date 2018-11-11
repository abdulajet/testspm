//
//  NXMEventsDispatcher.h
//  StitchObjC
//
//  Created by Doron Biaz on 9/5/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationCoreDelegate.h"
#import "NXMEventsDispatcherConstants.h"
#import "NXMEventsDispatcherNotificationHelper.h"

@interface NXMEventsDispatcher : NSObject  <NXMConversationCoreDelegate>
@property (readonly, nonatomic) NSNotificationCenter *notificationCenter;
@end
