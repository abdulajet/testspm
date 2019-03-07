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

- (nullable instancetype)initWithMemberId:(NSString *)memberId user:(NXMUser *)user andCallProxy:(id<NXMCallProxy>)callProxy {
    if (self = [super init]) {
        self.memberId = memberId;
        self.user = user;
        self.callProxy = callProxy;
        self.status = NXMCallMemberStatusDialling;
    }
    
    return self;
}

- (nullable instancetype)initWithMember:(NXMMember *)member andCallProxy:(id<NXMCallProxy>)callProxy {
    if (self = [self initWithMemberId:member.memberId user:member.user andCallProxy:callProxy]) {
        [self updateWithMember:member];
    }
    
    return self;
}

- (nullable instancetype)initWithMemberEvent:(NXMMemberEvent *)memberEvent andCallProxy:(id<NXMCallProxy>)callProxy {
    if (self = [self initWithMemberId:memberEvent.memberId user:memberEvent.user andCallProxy:callProxy]) {
        [self updateWithMemberEvent:memberEvent];
    }
    
    return self;
}

- (NSString *)statusDescription {
    switch (self.status) {
        case NXMCallMemberStatusDialling:
            return @"Dialling";
        case NXMCallMemberStatusCalling:
            return @"Calling";
        case NXMCallMemberStatusStarted:
            return @"Started";
        case NXMCallMemberStatusAnswered:
            return @"Answered";
        case NXMCallMemberStatusCancelled:
            return @"Cancelled";
        case NXMCallMemberStatusCompleted:
            return @"Completed";
        default:
            return @"Unknown";
    }
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
    [self updateWithMemberStatus:member.state isMedia:NO];
}

- (void)updateWithMemberEvent:(NXMMemberEvent *)memberEvent {
    [self updateWithMemberStatus:memberEvent.state isMedia:memberEvent.media.isEnabled];
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
