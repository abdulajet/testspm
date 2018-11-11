//
//  NXMConversationCoreDelegate.h
//  StitchObjC
//
//  Created by Chen Lev on 7/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//
#import "NXMConversationCoreEventsDelegate.h"
#import "NXMConversationCoreConnectionDelegate.h"


@protocol NXMConversationCoreDelegate <NSObject, NXMConversationCoreEventsDelegate, NXMConversationCoreConnectionDelegate>

@end
