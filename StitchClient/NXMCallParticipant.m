//
//  CallParticipant.m
//  StitcClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "StitchCore.h"

#import "NXMCallParticipant.h"
#import "NXMCallProxy.h"

@interface NXMCallParticipant()

@property (nonatomic, readwrite) NSString *callId;
@property (nonatomic, readwrite) NSString *memberId;
@property (nonatomic, readwrite) NXMParticipantStatus status;
@property (nonatomic, readwrite) BOOL isMuted;

@property (nonatomic, readwrite) id<NXMCallProxy> callProxy; // tmp

@end

@implementation NXMCallParticipant

- (nullable instancetype)initWithMemberId:(NSString *)memberId andCallProxy:(id<NXMCallProxy>)callProxy {
    if (self = [super init]) {
        self.callProxy = callProxy;
        self.memberId = memberId;
        self.status = NXMParticipantStatusDailing;
    }
    
    return self;
}

- (nullable instancetype)initWithMember:(NXMMember *)member andCallProxy:(id<NXMCallProxy>)callProxy {
    if (self = [self initWithMemberId:member.memberId andCallProxy:callProxy]) {
        [self updateWithMember:member];
    }
    
    return self;
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

- (void)updateWithMedia:(NXMMediaEvent *)media {
    self.status = media.mediaSettings.isEnabled ? NXMParticipantStatusAnswered : NXMParticipantStatusCompleted;
    self.isMuted = media.mediaSettings.isSuspended;
    
    [self.callProxy onChange];
}


- (void)updateWithMember:(NXMMember *)member {
    switch (member.state) {
        case NXMMemberStateInvited:
            self.status = NXMParticipantStatusCalling;
            break;
        case NXMMemberStateLeft:
            self.status = self.status == NXMParticipantStatusStarted ? NXMParticipantStatusCancelled : NXMParticipantStatusCompleted;
            break;
        case NXMMemberStateJoined:
            //  self.status = member.media.isEnabled ? NXMParticipantStatusAnswered : NXMParticipantStatusStarted;  TODO: add memer event media
            break;
        default:
            break;
    }
    
    [self.callProxy onChange];
}

- (void)updateWithMemberEvent:(NXMMemberEvent *)member {
    switch (member.state) {
        case NXMMemberStateInvited:
            self.status = NXMParticipantStatusCalling;
            break;
        case NXMMemberStateLeft:
            self.status = self.status == NXMParticipantStatusStarted ? NXMParticipantStatusCancelled : NXMParticipantStatusCompleted;
            break;
        case NXMMemberStateJoined:
            self.status = member.media.isEnabled ? NXMParticipantStatusAnswered : NXMParticipantStatusStarted;
            break;
        default:
            break;
    }
    
    [self.callProxy onChange];
}

@end
