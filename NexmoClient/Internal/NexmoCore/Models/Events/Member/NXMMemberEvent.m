//
//  NXMMemberEvent.m
//  NexmoConversationObjC
//
//  Created by user on 21/03/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMemberEvent.h"
#import "NXMCoreEventsPrivate.h"
#import "NXMUserPrivate.h"
#import "NXMChannelPrivate.h"
#import "NXMMediaSettingsInternal.h"

@interface NXMMemberEvent()
@property (nonatomic, readwrite, nonnull) NXMUser *user;
@property (nonatomic, readwrite, nullable) NXMChannel *channel;
@property (nonatomic, readwrite, nullable) NXMMediaSettings *media;
@end

@implementation NXMMemberEvent

- (instancetype)initWithConversationId:(NSString *)conversationId
                            sequenceId:(NSUInteger)sequenceId
                              andState:(NXMMemberState)state
                               andData:(NSDictionary *)data
                          creationDate:(NSDate *)date
                              memberId:(NSString *)memberId {
    
    NSString *fromKey = state == NXMMemberStateInvited ? @"invited" :
                        state == NXMMemberStateJoined ? @"joined" :
                        @"left";
    if (self = [super initWithConversationId:conversationId
                                  sequenceId:sequenceId
                                fromMemberId:data[@"initiator"][fromKey][@"member_id"]
                                creationDate:date
                                        type:NXMEventTypeMember]) {
        
        self.memberId = memberId;
        self.user =  [[NXMUser alloc] initWithData:data[@"user"]];
        self.state = state;
        self.media = [[NXMMediaSettings alloc] initWithEnabled:(data[@"media"] != nil ? [data[@"media"][@"audio"] boolValue] : NO) suspend:NO];
        self.knockingId = data[@"channel"][@"knocking_id"];
        self.channel = [[NXMChannel alloc] initWithData:data[@"channel"] andConversationId:conversationId andMemberId:memberId];
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@ memberId=%@ state=%ld user=%@ media=%@ channel=%@ knockingId=%@",
            NSStringFromClass([self class]),
            self,
            super.description,
            self.memberId,
            (long)self.state,
            self.user,
            self.media,
            self.channel,
            self.knockingId];
}


@end
