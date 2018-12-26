//
//  NXMTextEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMessageEvent.h"

@interface NXMTextEvent : NXMMessageEvent
@property (nonatomic, strong) NSString *text;
// TODO: type
@end
