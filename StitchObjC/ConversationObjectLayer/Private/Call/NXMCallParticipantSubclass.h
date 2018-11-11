//
//  NXMCallParticipantSubclass.h
//  Stitch_iOS
//
//  Created by Chen Lev on 11/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCallParticipant.h"

@protocol NXMCallProxy;

@interface NXMCallParticipant (NXMCallParticipantPrivate)

- (nullable instancetype)initWithMemberId:(NSString *)memberId andCallProxy:(id<NXMCallProxy>)callProxy;
- (nullable instancetype)initWithMember:(NXMMember *)member andCallProxy:(id<NXMCallProxy>)callProxy;

- (void)updateWithMember:(NXMMemberEvent *)member;
- (void)updateWithMedia:(NXMMediaEvent *)media;

@end
