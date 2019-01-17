//
//  NXMCallMember.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCallMember.h"
#import "NXMCallProxy.h"
#import "NXMMember.h"
#import "NXMCoreEvents.h"

@interface NXMCallMember()

@property (nonatomic, readwrite) NSString *callId;
@property (nonatomic, readwrite) NSString *memberId;
@property (nonatomic, readwrite) NXMCallMemberStatus status;
@property (nonatomic, readwrite) NXMUser *user;
@property (nonatomic, readwrite) BOOL isMuted;

@property (nonatomic, readwrite, weak) id<NXMCallProxy> callProxy; // tmp

@end

@implementation NXMCallMember

- (nullable instancetype)initWithMemberId:(NSString *)memberId andCallProxy:(id<NXMCallProxy>)callProxy {
    if (self = [super init]) {
        self.callProxy = callProxy;
        self.memberId = memberId;
        self.status = NXMCallMemberStatusDialling;
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

- (void)updateWithMediaEvent:(NXMEvent *)mediaEvent {
    
    NXMCallMemberStatus newStatus = self.status;
    BOOL isMuted = self.isMuted;
    
    if (mediaEvent.type == NXMEventTypeMedia) {
        NXMMediaEvent *mediaEventCast = (NXMMediaEvent *)mediaEvent;
        newStatus = mediaEventCast.mediaSettings.isEnabled ? NXMCallMemberStatusAnswered : NXMCallMemberStatusCompleted;
        isMuted = mediaEventCast.mediaSettings.isSuspended;
    } else if ([mediaEvent isKindOfClass:[NXMMediaSuspendEvent class]]){
       isMuted = ((NXMMediaSuspendEvent *)mediaEvent).isSuspended;
    }
    
    if (newStatus != self.status || isMuted != self.isMuted) {
        self.status = newStatus;
        self.isMuted = isMuted;
        
        [self.callProxy onChange:self];
        return;
    }

}


- (void)updateWithMember:(NXMMember *)member {
    self.user = member.user;
    
    [self updateWithMemberStatus:member.state isMedia:NO];
}

- (void)updateWithMemberEvent:(NXMMemberEvent *)member {
    self.user = member.user;
    
    [self updateWithMemberStatus:member.state isMedia:member.media.isEnabled];
}

- (void)updateWithMemberStatus:(NXMMemberState)state isMedia:(BOOL)isMedia {
    NXMCallMemberStatus newStatus = self.status;
    switch (state) {
        case NXMMemberStateInvited:
            newStatus = NXMCallMemberStatusCalling;
            break;
        case NXMMemberStateLeft:
            newStatus = self.status == NXMCallMemberStatusCalling ? NXMCallMemberStatusCancelled : NXMCallMemberStatusCompleted;
            break;
        case NXMMemberStateJoined:
            if (self.status != NXMCallMemberStatusAnswered) {
                newStatus = isMedia ? NXMCallMemberStatusAnswered : NXMCallMemberStatusStarted;
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
