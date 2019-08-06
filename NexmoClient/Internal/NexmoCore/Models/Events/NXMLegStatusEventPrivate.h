//
//  NXMLegStatusEventPrivate.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMLegStatusEvent.h"


@interface NXMLegStatusEvent (Private)

- (instancetype) initWithConversationId:(NSString*) conversationId
                                andData:(NSDictionary *)data;
@end
