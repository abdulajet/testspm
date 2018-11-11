//
//  NXMTextEvent.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/12/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMessageEvent.h"

@interface NXMTextEvent : NXMMessageEvent
@property (nonatomic, strong) NSString *text;
// TODO: type
@end
