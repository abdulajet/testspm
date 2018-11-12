//
//  NXMStitchCore.h
//  StitchCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "NXMStitchCoreDelegate.h"
#import "NXMUser.h"
#import "NXMNetworkCallbacks.h"
#import "NXMBlocks.h"
#import "NXMErrors.h"

#import "NXMGetConversationsRequest.h" // remove

@interface NXMStitchCore : NSObject

@property (readonly) BOOL isLoggedIn;
@property (readonly) BOOL isConnected;

- (instancetype _Nullable)init;
//- (instancetype _Nullable)initWithConfig:(nonnull NXMConversationClientConfig *)config; // TODO: can update config?

- (void)loginWithAuthToken:(nonnull NSString *)authToken;
- (void)logout;

- (void)enablePushNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
                                     isSandbox:(BOOL)isSandbox
                      onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                        onError:(NXMErrorCallback _Nullable)onError;

- (void)disablePushNotificationsWithOnSuccess:(NXMSuccessCallback _Nullable)onSuccess
                        onError:(NXMErrorCallback _Nullable)onError;

- (BOOL)isStitchPushWithUserInfo:(nonnull NSDictionary *)userInfo;

- (void)processStitchPushWithUserInfo:(nonnull NSDictionary *)userInfo onSuccess:(NXMSuccessCallbackWithEvent _Nullable)onSuccess onError:(NXMErrorCallback _Nullable)onError;

#pragma mark - Conversation Methods

- (void)createConversationWithName:(nonnull NSString *)name
             onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
               onError:(NXMErrorCallback _Nullable)onError;

- (void)joinToConversation:(nonnull NSString *)conversationId
  withUserId:(nonnull NSString *)userId
   onSuccess:(NXMSuccessCallbackWithObject _Nullable)onSuccess
     onError:(NXMErrorCallback _Nullable)onError;

- (void)joinToConversation:(nonnull NSString *)conversationId
withMemberId:(nonnull NSString *)memberId
   onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
     onError:(NXMErrorCallback _Nullable)onError;

- (void)inviteToConversation:(nonnull NSString *)conversationId
    withUserId:(nonnull NSString *)userId
     onSuccess:(NXMSuccessCallbackWithObject _Nullable)onSuccess
       onError:(NXMErrorCallback _Nullable)onError;

- (void)inviteToConversation:(nonnull NSString *)conversationId
                  withUserId:(nonnull NSString *)userId
                  withMedia:(nonnull NSString *)mediaEnabled
                   onSuccess:(NXMSuccessCallbackWithObject _Nullable)onSuccess
                     onError:(NXMErrorCallback _Nullable)onError;

- (void)inviteToConversation:(nonnull NSString *)conversationId
    withUserId:(nonnull NSString *)userId
withPhoneNumber:(nonnull NSString *)phoneNumber
     onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
       onError:(NXMErrorCallback _Nullable)onError;

- (void)inviteToConversation:(nonnull NSString *)userName
withPhoneNumber:(nonnull NSString *)phoneNumber
     onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
       onError:(NXMErrorCallback _Nullable)onError;

- (void)deleteMember:(nonnull NSString *)memberId
fromConversationWithId:(nonnull NSString *)conversationId
           onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
             onError:(NXMErrorCallback _Nullable)onError;

- (void)getEventsInConversation:(nonnull NSString *)conversationId
        onSuccess:(NXMSuccessCallbackWithEvents _Nullable)onSuccess
          onError:(NXMErrorCallback _Nullable)onError;

- (void)getEventsInConversation:(nonnull NSString *)conversationId
          startId:(nullable NSNumber *)startId
            endId:(nullable NSNumber *)endId
        onSuccess:(NXMSuccessCallbackWithEvents _Nullable)onSuccess
          onError:(NXMErrorCallback _Nullable)onError;

- (void)getConversations:(nonnull NXMGetConversationsRequest *)getConvetsationsRequest
               onSuccess:(NXMSuccessCallbackWithConversations _Nullable)onSuccess
                 onError:(NXMErrorCallback _Nullable)onError;

- (void)getConversationDetails:(nonnull NSString *)conversationId
                     onSuccess:(NXMSuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(NXMErrorCallback _Nullable)onError;

- (void)getConversationsForUser:(nonnull NSString *)userId
                   onSuccess:(NXMSuccessCallbackWithConversations _Nullable)onSuccess
                     onError:(NXMErrorCallback _Nullable)onError;

#pragma mark - Messages Methods

- (void)sendText:(nonnull NSString *)text
  conversationId:(nonnull NSString *)conversationId
    fromMemberId:(nonnull NSString *)fromMemberId
       onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
         onError:(NXMErrorCallback _Nullable)onError;

- (void)sendImageWithName:(nonnull NSString *)imageName
            image:(nonnull NSData *)image
   conversationId:(nonnull NSString *)conversationId
     fromMemberId:(nonnull NSString *)fromMemberId
        onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
          onError:(NXMErrorCallback _Nullable)onError;

- (void)deleteEvent:(NSInteger)eventId
     conversationId:(nonnull NSString *)conversationId
       fromMemberId:(nonnull NSString *)memberId
          onSuccess:(NXMSuccessCallback _Nullable)onSuccess
            onError:(NXMErrorCallback _Nullable)onError;

- (void)markAsSeen:(NSInteger)messageId
    conversationId:(nonnull NSString *)conversationId
  fromMemberWithId:(nonnull NSString *)memberId
         onSuccess:(NXMSuccessCallback _Nullable)onSuccess
           onError:(NXMErrorCallback _Nullable)onError;

- (void)markAsDelivered:(NSInteger)messageId
         conversationId:(nonnull NSString *)conversationId
       fromMemberWithId:(nonnull NSString *)memberId
              onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                onError:(NXMErrorCallback _Nullable)onError;

- (void)startTyping:(nonnull NSString *)conversationId
           memberId:(nonnull NSString *)memberId
          onSuccess:(NXMSuccessCallback _Nullable)onSuccess
            onError:(NXMErrorCallback _Nullable)onError;

- (void)stopTyping:(nonnull NSString *)conversationId
          memberId:(nonnull NSString *)memberId
         onSuccess:(NXMSuccessCallback _Nullable)onSuccess
           onError:(NXMErrorCallback _Nullable)onError;

#pragma mark - Media Methods

- (NXMStitchErrorCode)enableMedia:(nonnull NSString *)conversationId
                         memberId:(nonnull NSString *)memberId;

- (NXMStitchErrorCode)disableMedia:(nonnull NSString *)conversationId;

- (NXMStitchErrorCode)suspendMyMedia:(NXMMediaType)mediaType
                    inConversation:(nonnull NSString *)conversationId;

//TODO: add callback functionality?
//                         onSuccess:(SuccessCallback _Nullable)onSuccess
//                           onError:(ErrorCallback _Nullable)onError;
//TODO: not have a return error and a callback.
- (NXMStitchErrorCode)resumeMyMedia:(NXMMediaType)mediaType
                   inConversation:(nonnull NSString *)conversationId;
//TODO: add callback functionality?
//                         onSuccess:(SuccessCallback _Nullable)onSuccess
//                           onError:(ErrorCallback _Nullable)onError;


- (NXMStitchErrorCode)sendDTMFWithDigits:(nonnull NSString*)digits
                       andConversationId:(nonnull NSString*)conversationId
                             andMemberId:(nonnull NSString*)memberId
                             andDuration:(int) duration
                                  andGap:(int) gap;


- (void)suspendMedia:(NXMMediaType)mediaType
            ofMember:(nonnull NSString *)memberId
      inConversation:(nonnull NSString *)conversationId
          fromMember:(nonnull NSString *)fromMemberId
           onSuccess:(NXMSuccessCallback _Nullable)onSuccess
             onError:(NXMErrorCallback _Nullable)onError;

- (void)resumeMedia:(NXMMediaType)mediaType
           ofMember:(nonnull NSString *)memberId
     inConversation:(nonnull NSString *)conversationId
         fromMember:(nonnull NSString *)fromMemberId
          onSuccess:(NXMSuccessCallback _Nullable)onSuccess
            onError:(NXMErrorCallback _Nullable)onError;


#pragma mark - other Methods

- (nullable NXMUser *)getUser;
- (nullable NSString *)getToken;

- (void)setDelgate:(nonnull id<NXMStitchCoreDelegate>)delegate;
- (void)unregisterEvents;

@end
