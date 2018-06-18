//
//  NexmoConversationObjC.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for NexmoConversationObjC.
FOUNDATION_EXPORT double StitchObjCVersionNumber;

//! Project version string for NexmoConversationObjC.
FOUNDATION_EXPORT const unsigned char StitchObjCVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NexmoConversationObjC/PublicHeader.h>

@protocol NXMResponseDelegate;
@protocol NXMConversationClientDelegate;
@class NXMConnectionStatus;
@class NXMTextEvent;


#import "NXMConversationDetails.h"
#import "NXMNetworkCallbacks.h"
#import "NXMErrors.h"
#import "NXMUser.h"
#import "NXMMember.h"
#import "NXMTextStatusEvent.h"
#import "NXMTextTypingEvent.h"
#import "NXMMediaEvent.h"
#import "NXMMemberEvent.h"
#import "NXMImageEvent.h"

#import "NXMGetConversationsRequest.h"
#import "NXMGetEventsRequest.h"

#pragma mark - SDK Integration

#pragma mark - NXMConfig
/** ---------------------------------------------------------------------------------------
 * @name NXMConfig SDK Integration
 *  ---------------------------------------------------------------------------------------
 */
//
//@interface NXMConversationClientConfig : NSObject
//
//- (nonnull NSString *)getWSHost;
//- (nonnull NSString *)getHttpHost;
//
//@end

#pragma mark - StitchConversationClientCore

/** ---------------------------------------------------------------------------------------
 * @name StitchConversationClientCore SDK Integration
 *  ---------------------------------------------------------------------------------------
 */
@interface StitchConversationClientCore:NSObject

- (instancetype _Nullable)init;
//- (instancetype _Nullable)initWithConfig:(nonnull NXMConversationClientConfig *)config; // TODO: can update config?
- (void)enablePushNotifications:(BOOL)enable responseBlock:(void (^_Nullable)(NSError * _Nullable error))responseBlock;
- (void)loginWithAuthToken:(nonnull NSString *)authToken
                 onSuccess:(SuccessCallbackWithObject _Nullable)onSuccess
                   onError:(ErrorCallback _Nullable)onError;
- (void)logout:(void (^_Nullable)(NSError * _Nullable error))responseBlock;

#pragma mark - Conversation Methods

- (void)createWithName:(nonnull NSString *)name
             onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
               onError:(ErrorCallback _Nullable)onError;

- (void)join:(nonnull NSString *)conversationId
  withUserId:(nonnull NSString *)userId
   onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
     onError:(ErrorCallback _Nullable)onError;

- (void)join:(nonnull NSString *)conversationId
  withMemberId:(nonnull NSString *)memberId
   onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
     onError:(ErrorCallback _Nullable)onError;

- (void)invite:(nonnull NSString *)conversationId
    withUserId:(nonnull NSString *)userId
     onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
       onError:(ErrorCallback _Nullable)onError;

- (void)deleteMember:(nonnull NSString *)memberId
    fromConversationWithId:(nonnull NSString *)conversationId
           onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
             onError:(ErrorCallback _Nullable)onError;

- (void)getEvents:(nonnull NSString *)getEventsRequest
        onSuccess:(SuccessCallbackWithEvents _Nullable)onSuccess
          onError:(ErrorCallback _Nullable)onError;

- (void)getEvents:(nonnull NSString *)conversationId
          startId:(nullable NSNumber *)startId
            endId:(nullable NSNumber *)endId
        onSuccess:(SuccessCallbackWithEvents _Nullable)onSuccess
          onError:(ErrorCallback _Nullable)onError;

- (void)getConversations:(nonnull NXMGetConversationsRequest *)getConvetsationsRequest
               onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                 onError:(ErrorCallback _Nullable)onError;

- (void)getConversationDetails:(nonnull NSString *)conversationId
                     onSuccess:(SuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(ErrorCallback _Nullable)onError;

- (void)getConversationEvents:(nonnull NSString *)conversationId
                  startOffset:(NSUInteger)startOffset
                    endOffset:(NSUInteger)endOffset
               onSuccess:(SuccessCallbackWithObjects _Nullable)onSuccess
                 onError:(ErrorCallback _Nullable)onError;

- (void)getUserConversations:(nonnull NSString *)userId
                   onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                     onError:(ErrorCallback _Nullable)onError;

#pragma mark - Messages Methods

- (void)sendText:(nonnull NSString *)text
  conversationId:(nonnull NSString *)conversationId
    fromMemberId:(nonnull NSString *)fromMemberId
       onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
         onError:(ErrorCallback _Nullable)onError;

- (void)sendImage:(nonnull NSString *)imageName
            image:(nonnull NSData *)image
  conversationId:(nonnull NSString *)conversationId
    fromMemberId:(nonnull NSString *)fromMemberId
       onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
         onError:(ErrorCallback _Nullable)onError;

- (void)deleteText:(NSInteger)eventId
      conversationId:(nonnull NSString *)conversationId
        fromMemberId:(nonnull NSString *)memberId
           onSuccess:(SuccessCallback _Nullable)onSuccess
             onError:(ErrorCallback _Nullable)onError;

- (void)markAsSeen:(NSInteger)messageId
    conversationId:(nonnull NSString *)conversationId
  fromMemberWithId:(nonnull NSString *)memberId
         onSuccess:(SuccessCallback _Nullable)onSuccess
           onError:(ErrorCallback _Nullable)onError;

- (void)markAsDelivered:(NSInteger)messageId
    conversationId:(nonnull NSString *)conversationId
  fromMemberWithId:(nonnull NSString *)memberId
         onSuccess:(SuccessCallback _Nullable)onSuccess
           onError:(ErrorCallback _Nullable)onError;

- (void)startTyping:(nonnull NSString *)conversationId
           memberId:(nonnull NSString *)memberId
          onSuccess:(SuccessCallback _Nullable)onSuccess
            onError:(ErrorCallback _Nullable)onError;

- (void)stopTyping:(nonnull NSString *)conversationId
          memberId:(nonnull NSString *)memberId
         onSuccess:(SuccessCallback _Nullable)onSuccess
           onError:(ErrorCallback _Nullable)onError;

#pragma mark - Media Methods

- (NXMStitchErrorCode)enableMedia:(nonnull NSString *)conversationId
                         memberId:(nonnull NSString *)memberId;

- (NXMStitchErrorCode)disableMedia:(nonnull NSString *)conversationId;

#pragma mark - other Methods

- (nonnull NXMConnectionStatus *)getConnectionStatus;
- (nonnull NXMUser *)getUser;
- (nonnull NSString *)getToken;
- (BOOL)isLoggedIn; // TODO: the use already login but the network is down?

- (void)setDelgate:(nonnull id<NXMConversationClientDelegate>)delegate;
- (void)unregisterEvents;


@end


#pragma mark - NXMConversationClientDelegate
@protocol NXMConversationClientDelegate <NSObject>
/** ---------------------------------------------------------------------------------------
 * @name NXMConversationClientDelegate SDK Integration
 *  ---------------------------------------------------------------------------------------
 */

- (void)connectedWithUser:(NXMUser *_Nonnull)user;
- (void)connectionStatusChange:(NXMConnectionStatus *_Nonnull)status;

- (void)memberJoined:(nonnull NXMMemberEvent *)member;
- (void)memberInvited:(nonnull NXMMemberEvent *)member;
- (void)memberRemoved:(nonnull NXMMemberEvent *)member;

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent;

- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent;
- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent;
- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent;

- (void)imageRecieved:(nonnull NXMImageEvent *)textEvent;
- (void)imageDeleted:(nonnull NXMTextStatusEvent *)textEvent;
- (void)imageDelivered:(nonnull NXMTextStatusEvent *)textEvent;
- (void)imageSeen:(nonnull NXMTextStatusEvent *)textEvent;

- (void)mediaChanged:(nonnull NXMMediaEvent *)mediaEvent;

- (void)localMediaChanged:(nonnull NXMMediaEvent *)mediaEvent;
@end







