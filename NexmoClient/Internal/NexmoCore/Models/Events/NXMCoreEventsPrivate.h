//
//  NXMEventPrivate.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMCoreEvents.h"
#import "NXMMemberEventPrivate.h"
#import "NXMLegStatusEventPrivate.h"

@interface NXMEvent (NXNEventPrivate)

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationId
                                     sequenceId:(NSInteger)sequenceId
                                   fromMemberId:(nullable NSString *)fromMemberId
                                   creationDate:(nullable NSDate *)creationDate
                                           type:(NXMEventType)type;

@end

@interface NXMDTMFEvent (NXMDTMFEventPrivate)

- (instancetype)initWithDigit:(NSString *)digits andDuration:(NSNumber *)duration;

@end
