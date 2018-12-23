//
//  CallProxy.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

@class NXMCallParticipant;

@protocol NXMCallProxy

- (void)hold:(NXMCallParticipant *)participant isHold:(BOOL)isHold;
- (void)mute:(NXMCallParticipant *)participant isMuted:(BOOL)isMuted;
- (void)earmuff:(NXMCallParticipant *)participant isEarmuff:(BOOL)isEarmuff;

- (void)onChange:(NXMCallParticipant *)participant;

@end
