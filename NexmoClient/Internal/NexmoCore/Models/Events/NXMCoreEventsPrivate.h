//
//  NXMEventPrivate.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMCoreEvents.h"
#import "NXMMemberEventPrivate.h"
#import "NXMLegStatusEventPrivate.h"
#import "NXMCustomEventInternal.h"

@interface NXMEvent (NXNEventPrivate)

- (instancetype)initWithConversationId:(NSString *)conversationId
                                     sequenceId:(NSInteger)sequenceId
                                   fromMemberId:(NSString *)fromMemberId
                                   creationDate:(NSDate *)creationDate
                                           type:(NXMEventType)type;

@end

@interface NXMDTMFEvent (NXMDTMFEventPrivate)

- (instancetype)initWithDigit:(NSString *)digits andDuration:(NSNumber *)duration;

@end
