//
//  NXMTextTypingEvent.h
//  NexmoConversationObjC
//
//  Created by user on 08/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMTextTypingEvent_h
#define NXMTextTypingEvent_h
#include "NXMTextEvent.h"
#include "NXMTextTypingEventStatus.h"

@interface NXMTextTypingEvent : NXMEvent
@property (nonatomic) NXMTextTypingEventStatus status;
@end

#endif /* NXMTextTypingEvent_h */
