//
//  CallParticipant.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCallParticipant.h"
#import "NXMCallProxy.h"
#import "NXMMember.h"
#import "NXMCoreEvents.h"

@interface NXMCallParticipant()

@property (nonatomic, readwrite) NSString *callId;
@property (nonatomic, readwrite) NSString *participantId;
@property (nonatomic, readwrite) NXMParticipantStatus status;
@property (nonatomic, readwrite) NSString *userId;
@property (nonatomic, readwrite) NSString *userName;
@property (nonatomic, readwrite) BOOL isMuted;

@property (nonatomic, readwrite) id<NXMCallProxy> callProxy; // tmp

@end

@implementation NXMCallParticipant

- (nullable instancetype)initWithMemberId:(NSString *)memberId andCallProxy:(id<NXMCallProxy>)callProxy {
    if (self = [super init]) {
        self.callProxy = callProxy;
        self.participantId = memberId;
        self.status = NXMParticipantStatusDialing;
    }
    
    return self;
}

- (nullable instancetype)initWithMember:(NXMMember *)member andCallProxy:(id<NXMCallProxy>)callProxy {
    if (self = [self initWithMemberId:member.memberId andCallProxy:callProxy]) {
        [self updateWithMember:member];
    }
    
    return self;
}

- (void)hangup {
    [self.callProxy hangup:self];
}

- (void)hold:(BOOL)isHold {
    [self.callProxy hold:self isHold:isHold];
}

- (void)mute:(BOOL)isMute {
    [self.callProxy mute:self isMuted:isMute];
}

- (void)earmuff:(BOOL)isEarmuff {
    [self.callProxy earmuff:self isEarmuff:isEarmuff];
}

- (void)updateWithMedia:(NXMEvent *)media {
    
    NXMParticipantStatus newStatus = self.status;
    BOOL isMuted = self.isMuted;
    
    if (media.type == NXMEventTypeMedia) {
        NXMMediaEvent *eventMedia = (NXMMediaEvent *)media;
        newStatus = eventMedia.mediaSettings.isEnabled ? NXMParticipantStatusAnswered : NXMParticipantStatusCompleted;
        isMuted = eventMedia.mediaSettings.isSuspended;
    } else if ([media isKindOfClass:[NXMMediaSuspendEvent class]]){
       isMuted = ((NXMMediaSuspendEvent *)media).isSuspended;
    }
    
    if (newStatus != self.status || isMuted != self.isMuted) {
        self.status = newStatus;
        self.isMuted = isMuted;
        
        [self.callProxy onChange:self];
        return;
    }

}


- (void)updateWithMember:(NXMMember *)member {
    self.userId = member.userId;
    self.userName = member.name;
    
    [self updateWithMemberStatus:member.state isMedia:NO];
}

- (void)updateWithMemberEvent:(NXMMemberEvent *)member {
    self.userId = member.user.userId;
    self.userName = member.user.name;
    
    [self updateWithMemberStatus:member.state isMedia:member.media.isEnabled];
}

- (void)updateWithMemberStatus:(NXMMemberState)state isMedia:(BOOL)isMedia {
    NXMParticipantStatus newStatus = self.status;
    switch (state) {
        case NXMMemberStateInvited:
            newStatus = NXMParticipantStatusCalling;
            break;
        case NXMMemberStateLeft:
            newStatus = self.status == NXMParticipantStatusCalling ? NXMParticipantStatusCancelled : NXMParticipantStatusCompleted;
            break;
        case NXMMemberStateJoined:
            if (self.status != NXMParticipantStatusAnswered) {
                newStatus = isMedia ? NXMParticipantStatusAnswered : NXMParticipantStatusStarted;
            }
            break;
        default:
            break;
    }
    

    if (newStatus != self.status) {
        self.status = newStatus;
        [self.callProxy onChange:self];
    }
}

@end
