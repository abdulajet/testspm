//
//  NXMCall.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

@import Foundation;

#import "NXMEnums.h"
#import "NXMBlocks.h"

@class NXMConversation;
@class NXMMember;
@class NXMCall;

/**
 * A list of the call handlers.
 */
typedef NS_ENUM(NSInteger, NXMCallHandler) {
    /// A default call behavior - use it only for IP to IP calls.
    NXMCallHandlerInApp,
    /// A webhook call, can use it for IP to IP and IP to PSTN.
    NXMCallHandlerServer
} OBJC_DEPRECATED("Used by the deprecated [NXMClient call:callHandler:completionHandler:] method");

/**
 The NXMCallDelegate should be use as the `NXMCall` delegate.
 The NXMCallDelegate notifies on NXMCall object updates.
 */
@protocol NXMCallDelegate <NSObject>

/**
 * Notify on call member updates
 * @param call A `NXMCall` object - the call that updated
 * @param member A `NXMMember` object - the call member that updated
 * @param status A `NXMCallMemberStatus` status
 */
- (void)call:(nonnull NXMCall *)call didUpdate:(nonnull NXMMember *)member withStatus:(NXMCallMemberStatus)status;

/**
 * Notify on call member updates
 * @param call A `NXMCall` object - the call that updated
 * @param member A `NXMMember` object - the call member that updated
 * @param muted The muted state
 */
- (void)call:(nonnull NXMCall *)call didUpdate:(nonnull NXMMember *)member isMuted:(BOOL)muted;

/**
 * Notify on call error
 * @param call A `NXMCall` object - the call that updated
 * @param error - A call error
 */
- (void)call:(nonnull NXMCall *)call didReceive:(nonnull NSError *)error;

@optional

/**
 * Notify on DTMF received
 * @param call A `NXMCall` object - the call that updated
 * @param dtmf A NSString which represent the dtmf value
 * @param member A `NXMMember` which the dtmf received from
 */
- (void)call:(nonnull NXMCall *)call didReceive:(nonnull NSString *)dtmf fromMember:(nullable NXMMember *)member;

@end


/**
 The NXMCall class is a `NXMConversation` for phone calls.
 @note NXMCall can be and incoming call or outgoing call.
 */
@interface NXMCall : NSObject

/// Conversation associated to the call.
@property (nonatomic, readonly, nonnull) NXMConversation *conversation;

/// Indicates my call member.
@property (nonatomic, readonly, nullable) NXMMember *myMember;

/// Indicates all the call members.
@property (nonatomic, readonly, nonnull) NSArray<NXMMember *> *allMembers;

/**
 * Set the delegate, `NXMCallDelegate`, for the call object.
 * @param delegate A NXMCallDelegate object.
 */
- (void)setDelegate:(nonnull id<NXMCallDelegate>)delegate;

#pragma call methods

/**
 * Answer an incoming call.
 * @warning You can only answer a call when the call member status is ringing.
 * @param completionHandler A `NXMErrorCallback` block.
 * @code [call answer:delegate completionHandler:^(NSError error){
         if (!error) {
            NSLog(@"answer the call failed");
            return;
         }

        NSLog(@"joined the call");
     }];
 */
- (void)answer:(NXMCompletionCallback _Nullable)completionHandler;


/**
 * Reject an incoming call.
 * @warning You can only answer a call when the call member status is ringing.
 * @param completionHandler A `NXMErrorCallback` block.
 * @code [call rejectWithCompletionHandler:delegate completionHandler:^(NSError error){
         if (!error) {
         NSLog(@"reject call failed");
         return;
         }

        NSLog(@"call rejected");
 }];
 */
- (void)reject:(NXMCompletionCallback _Nullable)completionHandler;

/**
 * Add a member to a call using a username.
 * @param username The username of the member you want to add.
 * @param completionHandler A `NXMErrorCallback` block.
 */
- (void)addCallMemberWithUsername:(nonnull NSString *)username
                completionHandler:(NXMCompletionCallback _Nullable)completionHandler;

/**
 * Add a member to a call using a number.
 * @param number The number of the member you want to add.
 * @param completionHandler A `NXMErrorCallback` block.
 */
- (void)addCallMemberWithNumber:(nonnull NSString *)number
              completionHandler:(NXMCompletionCallback _Nullable)completionHandler;

/**
 * Sends DTMF digits to the call.
 * @param dtmf The DTMF digit(s) to send.
 */
- (void)sendDTMF:(nonnull NSString *)dtmf;

/// Hangup an ongoing call.
- (void)hangup;

/**
 * Get the current call status giving a NXMMember.
 * @param member A `NXMMember` to get the current status from.
 */
- (NXMCallMemberStatus)callStatusForMember:(nonnull NXMMember *)member;

/// Mute the current user member.
- (void)mute;

/// Unmute the current user member.
- (void)unmute;

/// Reconnect the current call.
- (void)reconnect;

@end
