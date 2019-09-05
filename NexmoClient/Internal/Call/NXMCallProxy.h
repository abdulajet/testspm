//
//  CallProxy.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

@class NXMCallMember;

@protocol NXMCallProxy

- (void)hangup:(NXMCallMember *)callMember;
- (void)hold:(NXMCallMember *)callMember isHold:(BOOL)isHold;
- (void)mute:(NXMCallMember *)callMember isMuted:(BOOL)isMuted;
- (void)earmuff:(NXMCallMember *)callMember isEarmuff:(BOOL)isEarmuff;

- (void)didUpdate:(nonnull NXMCallMember *)callMember status:(NXMCallMemberStatus)status;
- (void)didUpdate:(nonnull NXMCallMember *)callMember muted:(BOOL)muted;

@end
