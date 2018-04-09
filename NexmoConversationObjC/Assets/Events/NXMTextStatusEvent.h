//
//  NXMDeleteEvent.h
//  NexmoConversationObjC
//
//  Created by user on 08/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMDeleteEvent_h
#define NXMDeleteEvent_h


#import "NXMEvent.h"
#import "NXMTextEventStatus.h"

@interface NXMTextStatusEvent : NXMEvent
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic) NXMTextEventStatusE status;
@end
#endif /* NXMDeleteEvent_h */
