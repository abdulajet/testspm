//
//  NXMCallMember.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMUser.h"
#import "NXMChannel.h"

/**
 * A list of the call member statuses.
 */
typedef NS_ENUM(NSInteger, NXMCallMemberStatus) {
    /// The call is initialized.
    NXMCallMemberStatusRinging,
    /// The server started the call.
    NXMCallMemberStatusStarted,
    /// The call is answered.
    NXMCallMemberStatusAnswered,
    /// The call is cancelled.
    NXMCallMemberStatusCancelled,
    /// The call failed.
    NXMCallMemberStatusFailed,
    /// The member being called is busy.
    NXMCallMemberStatusBusy,
    /// The member is unreachable within the timeout.
    NXMCallMemberStatusTimeout,
    /// The member rejected the call.
    NXMCallMemberStatusRejected,
    /// The call is completed.
    NXMCallMemberStatusCompleted
};

/**
 The NXMCallMember class is for members of a `NXMCall`.
 @note NXMCallMember differs from the `NXMMember` class.
 */
@interface NXMCallMember : NSObject

/// The ID for the member.
@property (nonatomic, copy, nonnull) NSString *memberId;

/// The `NXMUser` object for the member.
@property (nonatomic, readonly, nonnull) NXMUser *user;

/// The `NXMChannel` of the member's call.
@property (nonatomic, readonly, nullable) NXMChannel *channel;

/// Returns if the call member is muted or not.
@property (nonatomic, readonly) BOOL isMuted;

/// The `NXMCallMemberStatus` of the member.
@property (nonatomic, readonly) NXMCallMemberStatus status;

/// A String description of the  `NXMCallMemberStatus` of the member.
@property (nonatomic, copy, nonnull) NSString *statusDescription;

/**
 * Puts the call member on hold.
 * @param isHold Hold enabled.
 */
- (void)hold:(BOOL)isHold;

/**
 * Puts the call member on mute.
 * @param isMute Mute enabled.
 */
- (void)mute:(BOOL)isMute;

/**
 * Earmuffs the call member.
 * @param isEarmuff Earmuff enabled.
 */
- (void)earmuff:(BOOL) isEarmuff;

@end
