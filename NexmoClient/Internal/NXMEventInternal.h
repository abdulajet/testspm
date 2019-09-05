//
//  NXMEventInternal.h
//  NexmoClient
//
//  Created by Chen Lev on 9/4/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMEvent.h"

@interface NXMEvent (NXNEventPrivate)

@property (nonatomic, nonnull) NSString *fromMemberId;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationId
                                     sequenceId:(NSInteger)sequenceId
                                   fromMemberId:(nullable NSString *)fromMemberId
                                   creationDate:(nullable NSDate *)creationDate
                                           type:(NXMEventType)type;

- (void)updateFromMember:(nonnull NXMMember *)member;

@end

