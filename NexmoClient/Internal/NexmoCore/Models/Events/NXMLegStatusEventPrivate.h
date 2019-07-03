//
//  NXMLegStatusEventPrivate.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMLegStatusEvent.h"


@interface NXMLegStatusEvent (Private)

- (instancetype) initWithConversationId:(NSString*) conversationId
                                   type:(NXMEventType)type
                           fromMemberId:(NSString *)fromMemberId
                             sequenceId:(NSInteger)sequenceId
                             legHistory:(NSMutableArray<NXMLeg*>*) legs;

@end
