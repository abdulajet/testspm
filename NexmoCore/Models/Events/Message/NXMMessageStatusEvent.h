//
//  NXMDeleteEvent.h
//  NexmoConversationObjC
//
//  Created by user on 08/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//
#import "NXMEvent.h"

@interface NXMMessageStatusEvent : NXMEvent
@property NSInteger eventId;
@property (nonatomic) NXMMessageStatusType status;
@end

