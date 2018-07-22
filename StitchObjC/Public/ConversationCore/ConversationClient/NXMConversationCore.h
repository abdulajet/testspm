//
//  NXMConversationCore.h
//  StitchObjC
//
//  Created by Chen Lev on 7/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMConversationCoreDelegate.h"
#import "NXMNetworkCallbacks.h"
#import "NXMUser.h"
#import "NXMGetConversationsRequest.h"
#import "NXMErrors.h"

@interface NXMConversationCore : NSObject

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

- (void)invite:(nonnull NSString *)conversationId
    withUserId:(nonnull NSString *)userId
withPhoneNumber:(nonnull NSString *)phoneNumber
     onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
       onError:(ErrorCallback _Nullable)onError;

- (void)invite:(nonnull NSString *)userName
withPhoneNumber:(nonnull NSString *)phoneNumber
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

- (void)deleteEvent:(NSInteger)eventId
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

//- (nonnull NXMConnectionStatus *)getConnectionStatus;
- (nonnull NXMUser *)getUser;
- (nonnull NSString *)getToken;
- (BOOL)isLoggedIn; // TODO: the use already login but the network is down?

- (void)setDelgate:(nonnull id<NXMConversationCoreDelegate>)delegate;
- (void)unregisterEvents;

@end
