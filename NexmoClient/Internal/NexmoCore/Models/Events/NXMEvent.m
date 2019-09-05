//
//  NXMEvent.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/21/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEventInternal.h"

@interface NXMEvent()
@property (nonatomic, readwrite, nullable) NXMMember *fromMember;
@property (nonatomic, readwrite, nonnull) NSString *fromMemberId;

@end

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
        self.conversationUuid = conversationId;
        self.uuid = sequenceId;
        self.fromMemberId = fromMemberId;
        self.creationDate = creationDate;
        self.type = type;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> conversationId=%@ fromMemberId=%@ creationDate=%@ deletionDate=%@ type=%ld eventId=%ld",
            NSStringFromClass([self class]),
            self,
            self.conversationUuid,
            self.fromMemberId,
            self.creationDate,
            self.deletionDate,
            (long)self.type,
            (long)self.uuid];
}


- (void)updateFromMember:(NXMMember *)member {
    self.fromMember = member;
}
@end
