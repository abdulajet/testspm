//
//  NXMTextTypingEvent.h
//  NexmoConversationObjC
//
//  Created by user on 08/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"
#import "NXMEnums.h"

@interface NXMTextTypingEvent : NXMEvent
@property (nonatomic) NXMTextTypingEventStatus status;
@end

