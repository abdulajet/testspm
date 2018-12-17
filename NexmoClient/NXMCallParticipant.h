//
//  CallParticipant.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXMParticipantStatus) {
    NXMParticipantStatusDailing,
    NXMParticipantStatusCalling,
    NXMParticipantStatusStarted,
    NXMParticipantStatusAnswered,
    NXMParticipantStatusCancelled,
    NXMParticipantStatusCompleted
};

@interface NXMCallParticipant : NSObject

@property (nonatomic, readonly) NSString *callId;
@property (nonatomic, readonly) NSString *participantId;
@property (nonatomic, readonly) BOOL isMuted;
@property (nonatomic, readonly) NXMParticipantStatus status;
@property (nonatomic, readonly) NSString *metaInfo;

- (void)hold:(BOOL)isHold;
- (void)mute:(BOOL)isMute;
- (void)earmuff:(BOOL)isEarmuff;

@end



