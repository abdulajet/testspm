//
//  NXMMemberEvent.h
//  NexmoConversationObjC
//
//  Created by user on 21/03/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMMemberEvent_h
#define NXMMemberEvent_h

#import "NXMEvent.h"
#import "NXMUser.h"

@interface NXMMemberEvent : NXMEvent
@property (nonatomic, strong) NSString *memberId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NXMUser *user;
@property (nonatomic, strong) NSString* phoneNumber;
@end

#endif /* NXMMemberEvent_h */
