//
//  NXMCall.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMCallMember.h"
#import "NXMBlocks.h"

/*!
 * @typedef NXMCallHandler
 * @brief A list of the call handlers.
 * @constant NXMCallHandlerInApp a default call behavior - use it only for IP to IP calls.
 * @constant NXMCallHandlerServer a webhook call, can use it for IP to IP and IP to PSTN.
 */
typedef NS_ENUM(NSInteger, NXMCallHandler) {
    /// A default call behavior - use it only for IP to IP calls.
    NXMCallHandlerInApp,
    /// A webhook call, can use it for IP to IP and IP to PSTN.
    NXMCallHandlerServer
};

/*!
 @protocol NXMCallDelegate
 @brief The NXMCallDelegate should be use as the NXMCall delegate.
 @discussion NXMCallDelegate notify on NXMCall object updates.
 */
@protocol NXMCallDelegate <NSObject>

/*!
 * @brief Notify on call member updates
 * @param callMember A NXMCallMember object - the call member that updated
 */
- (void)statusChanged:(nonnull NXMCallMember *)callMember;
@optional

/*!
 * @brief Notify on DTMF received
 * @param dtmf A NSString which represent the dtmf value.
 * @param callMember A NXMCallMember which the dtmf received from.
 */
- (void)DTMFReceived:(nonnull NSString *)dtmf callMember:(nonnull NXMCallMember *)callMember;
@end


/*!
 @interface NXMCall
 @brief The NXMCall object represent a call.
 @discussion NXMCall can be and incoming call or outgoing call.
 */
@interface NXMCall : NSObject

/// Indicates all the call members except my call member.
@property (nonatomic, readonly, nonnull) NSMutableArray<NXMCallMember *> *otherCallMembers;

/// Indicates my call member.
@property (nonatomic, readonly, nonnull) NXMCallMember *myCallMember;

/*!
 * @brief set delegate for the call object.
 * @param delegate A NXMCallDelegate object.
 */
- (void)setDelegate:(nonnull id<NXMCallDelegate>)delegate;

#pragma call methods

/*!
 * @brief answer incoming call.
 * @warning can answer the call only when the call member status is calling.
 * @param delegate A NXMCallDelegate object.
 * @param completionHandler A NXMErrorCallback block.
 * @code [call answer:delegate completionHandler:^(NSError error){
         if (!error) {
            NSLog(@"answer the call failed");
            return;
         }
 
        NSLog(@"joined the call");
     }];
 */
- (void)answer:(nonnull id<NXMCallDelegate>)delegate completionHandler:(NXMErrorCallback _Nullable)completionHandler;


/*!
 * @brief reject incoming call.
 * @warning can reject the call only when the call member status is calling.
 * @param completionHandler A NXMErrorCallback block.
 * @code [call rejectWithCompletionHandler:delegate completionHandler:^(NSError error){
         if (!error) {
         NSLog(@"reject call failed");
         return;
         }
 
        NSLog(@"call rejected");
 }];
 */
- (void)rejectWithCompletionHandler:(NXMErrorCallback _Nullable)completionHandler;

- (void)addCallMemberWithUserId:(nonnull NSString *)userId completionHandler:(NXMErrorCallback _Nullable)completionHandler;

- (void)addCallMemberWithNumber:(nonnull NSString *)number completionHandler:(NXMErrorCallback _Nullable)completionHandler;

- (void)sendDTMF:(nonnull NSString *)dtmf;

- (void)hangup;

@end

