//
//  NXMMember.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMemberPrivate.h"

#import "NXMUserPrivate.h"
#import "NXMChannelPrivate.h"
#import "NXMLegPrivate.h"
#import "NXMInitiatorPrivate.h"
#import "NXMMediaSettingsInternal.h"
#import "NXMLoggerInternal.h"
#import "NXMEventInternal.h"
#import "NXMMemberEventPrivate.h"


@interface NXMMember()
@property (nonatomic, readwrite) NXMUser *user;
@property (nonatomic, readwrite) NXMMediaSettings *media;
@property (nonatomic, readwrite) NXMMemberState state;
@property (nonatomic, readwrite) NXMChannel *channel;
@property (nonatomic, readwrite) NSDictionary<NSValue *, NXMInitiator *> *initiators;

@end

@implementation NXMMember

- (instancetype)initWithMemberId:(NSString *)memberId
                  conversationId:(NSString *)conversationId
                            user:(NXMUser *)user
                           state:(NXMMemberState)state
                      initiators:(NSDictionary<NSValue *, NXMInitiator *> *)initiators
                           media:(NXMMediaSettings *)media
                           channel:(NXMChannel *)channel {
    if (self = [super init]) {
        self.memberId = memberId;
        self.conversationId = conversationId;
        self.user = user;
        self.state = state;
        self.channel = channel;
        self.initiators = initiators;
        self.media = media;
        self.channel = channel;
    }
    
    return self;
}

- (instancetype)initWithMemberEvent:(NXMMemberEvent *)memberEvent
{
    return [self initWithMemberId:memberEvent.memberId
                   conversationId:memberEvent.conversationId
                             user:memberEvent.user
                            state:memberEvent.state
                       initiators:@{@(memberEvent.state): [[NXMInitiator alloc] initWithTime:memberEvent.creationDate
                                                                                 andMemberId:memberEvent.fromMemberId]}
                            media:memberEvent.media
                          channel:memberEvent.channel];

}


- (nullable instancetype)initWithData:(NSDictionary *)data
                 andMemberIdFieldName:(NSString *)memberIdFieldName {
    return [self initWithData:data
         andMemberIdFieldName:memberIdFieldName
            andConversationId:data[@"conv_id"]];
}

- (nullable instancetype)initWithData:(NSDictionary *)data
                 andMemberIdFieldName:(NSString *)memberIdFieldName
                    andConversationId:(NSString *)convertaionId {
        return [self initWithMemberId:data[memberIdFieldName]
                       conversationId:convertaionId
                                 user:[[NXMUser alloc] initWithData:data]
                                state:[self parseMemberState:data[@"state"]]
                           initiators:[self parseInitiators:data]
                                media:[[NXMMediaSettings alloc]
                                       initWithEnabled:[data[@"media"][@"audio_settings"][@"enabled"] boolValue]
                                                suspend:[data[@"media"][@"audio_settings"][@"muted"] boolValue]]
                              channel:[[NXMChannel alloc] initWithData:data[@"channel"]
                                                     andConversationId:self.conversationId andMemberId:self.memberId]];

}



- (void)updateChannelWithLeg:(NXMLeg *)leg {
    LOG_DEBUG([leg.description UTF8String]);
    [self.channel addLeg:leg];

}

- (void)updateMedia:(NXMMediaSettings *)media {
    [self.media updateWithEnabled:media.isEnabled suspend:media.isSuspended];
}

- (void)updateState:(NXMMemberState)state time:(NSDate *)time initiator:(NSString *)initiator {
    self.state = state;
    
    NSMutableDictionary *updatedInitiators = [NSMutableDictionary new];
    for (NSValue *key in self.initiators.allKeys) {
        [updatedInitiators setObject:self.initiators[key] forKey:key];
    }
    [updatedInitiators setObject:[[NXMInitiator alloc] initWithTime:time andMemberId:initiator] forKey:@(state)];
    
    self.initiators = updatedInitiators;
}

- (void)updateExpired {
    LOG_DEBUG([self.memberId UTF8String]);
    self.state = NXMMemberStateLeft;
    
    NXMLeg *leg = self.channel.leg;
    if (!leg ||
        leg.status == NXMLegStatusCompleted) {
        LOG_ERROR("NXMMember %s updateExpired no relevant leg %s", [self.memberId UTF8String], [leg.uuid UTF8String]);

        return;
    }
    
    [self.channel addLeg:[[NXMLeg alloc] initWithConversationId:self.conversationId
             andMemberId:self.memberId
                andLegId:leg.uuid
              andlegTypeE:leg.type
            andLegStatusE:NXMLegStatusCompleted
                 andDate:NULL]];    
}

- (void)setMember:(NXMMember *)member {
    self.member = member;
}

#pragma Parser

- (NSDictionary *)parseInitiators:(NSDictionary *)data {
    NSMutableDictionary *initiators = [NSMutableDictionary new];
    
    for (NSString *state in @[@"invited", @"joined", @"left"]) {
        if (data[@"timestamp"][state]) {
            [initiators setObject:[[NXMInitiator alloc] initWithTime:data[@"timestamp"][state]
                                                             andData:data[@"initiator"][state]]
                           forKey:@([self parseMemberState:state])];
        }
    }
    
    return initiators;

}
    
- (NXMMemberState)parseMemberState:(NSString *)state {
    static NSDictionary *memberStateValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        memberStateValues = @{@"INVITED":@(NXMMemberStateInvited),
                              @"JOINED":@(NXMMemberStateJoined),
                              @"LEFT":@(NXMMemberStateLeft)};
    });
    return [memberStateValues[[state uppercaseString]] integerValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> conversationId=%@ memberId=%@ user=%@ state=%ld media=%@ channel=%@ initiators=%@",
            NSStringFromClass([self class]),
            self,
            self.conversationId,
            self.memberId,
            self.user,
            (long)self.state,
            self.media,
            self.channel,
            self.initiators];
}

@end
