//
//  NXMEvent.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/21/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"

@implementation NXMEvent

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationId
                                           type:(NXMEventType)type
                                   fromMemberId:(nullable)memberId
                                     sequenceId:(NSInteger)sequenceId {
    return [self initWithConversationId:conversationId sequenceId:sequenceId fromMemberId:memberId creationDate:NULL type:type];
}
- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationId
                                     sequenceId:(NSInteger)sequenceId
                                   fromMemberId:(nullable NSString *)fromMemberId
                                   creationDate:(nullable NSDate *)creationDate
                                           type:(NXMEventType)type {
    if (self = [super init]) {
        self.conversationId = conversationId;
        self.eventId = sequenceId;
        self.fromMemberId = fromMemberId;
        self.creationDate = creationDate;
        self.type = type;
    }
    
    return self;
}

@end
