//
//  OngoingMediaCollection.m
//  StitchTestApp
//
//  Created by Doron Biaz on 8/16/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "OngoingMediaCollection.h"

@implementation OngoingMediaCollection

-(instancetype)init {
    if(self = [super init]) {
        self.ongoingCallsArray = [NSMutableArray<OngoingMedia *> new];
        self.ongoingCallsMemberConversationToArrayIndex =[NSMutableDictionary<NSString *, NSMutableDictionary<NSString *,NSNumber *> *> new];
    }
    return self;
}

-(long)count {
    return self.ongoingCallsArray.count;
}

-(long)countForConversation:(NSString *)conversationId {
    return self.ongoingCallsMemberConversationToArrayIndex[conversationId]
    ? self.ongoingCallsMemberConversationToArrayIndex[conversationId].count
    : -1;
}

-(bool)addMedia:(OngoingMedia *)media ForMember:(nonnull NSString *)memberId inConversation:(nonnull NSString *)conversationId {
    if(!self.ongoingCallsMemberConversationToArrayIndex[conversationId]) {
        self.ongoingCallsMemberConversationToArrayIndex[conversationId] = [NSMutableDictionary new];
    }
    if(self.ongoingCallsMemberConversationToArrayIndex[conversationId][memberId]) {
        return false;
    }
    [self.ongoingCallsArray addObject:media];
    long index = self.ongoingCallsArray.count - 1;
    
    self.ongoingCallsMemberConversationToArrayIndex[conversationId][memberId] = [NSNumber numberWithLong:index];
    return true;
}

-(OngoingMedia *)getMediaForMember:(nonnull NSString *)memberId inConversation:(nonnull NSString *)conversationId {
    NSNumber *index = nil;
    if(index = [self getIndexForMember:memberId inConversation:conversationId]) {
        return [self getMediaForIndex:index];
    }
    return nil;
}

-(void)removeMediaForMember:(nonnull NSString *)memberId inConversation:(nonnull NSString *)conversationId {
    NSNumber *index = nil;
    if(index = [self getIndexForMember:memberId inConversation:conversationId]) {
        [self.ongoingCallsArray removeObjectAtIndex:[index longValue]];
        [self.ongoingCallsMemberConversationToArrayIndex[conversationId] removeObjectForKey:memberId];
        //TODO upadte the new indexes:
        for (long i = [index longValue]; i < self.ongoingCallsArray.count; i++) {
            OngoingMedia *mediaToUpdate =[self getMediaForIndex:[NSNumber numberWithLong:i]];
            self.ongoingCallsMemberConversationToArrayIndex[mediaToUpdate.conversationId][mediaToUpdate.memberId] = [NSNumber numberWithLong:i];
        }
    }
}

-(OngoingMedia *)getMediaForIndex:(nonnull NSNumber *)index {
    return [self.ongoingCallsArray objectAtIndex:[index longValue]];
}

-(NSNumber *)getIndexForMember:(NSString *)memberId inConversation:(NSString *)conversationId {
    return self.ongoingCallsMemberConversationToArrayIndex[conversationId][memberId];
}
@end
