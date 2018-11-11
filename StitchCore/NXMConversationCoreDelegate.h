//
//  NXMConversationCoreDelegate.h
//  StitchCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//
#import "NXMConversationCoreEventsDelegate.h"
#import "NXMConversationCoreConnectionDelegate.h"


@protocol NXMConversationCoreDelegate <NSObject, NXMConversationCoreEventsDelegate, NXMConversationCoreConnectionDelegate>

@end
