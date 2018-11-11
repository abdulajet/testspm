//
//  NXMStitch.h
//  StitcClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMStitchClientDelegate.h"
#import "NXMConversation.h"
#import "NXMCall.h"

@interface NXMStitchClient : NSObject

/*!
Return true when user logged in.
*/
@property (nonatomic, assign, readonly, getter=isLoggedIn) BOOL loggedIn;

/*!
 Return true when user is connected - loggedIn is true and network available.
 */
@property (nonatomic, assign, readonly, getter=isConnected) BOOL connected;


/*!
 Return the current user
 */
@property (nonatomic, strong, readonly, nullable, getter=getUser) NXMUser *user;

/*!
 Return the current authentication token
 */
@property (nonatomic, strong, readonly, nullable, getter=getToken) NSString *token;

/*!
 Set stitch client delegate
 *  @param delegate a `NXMStitchClientDelegate` object.
 *
 */
- (void)setDelegate:(nullable id <NXMStitchClientDelegate>)delegate;

/**
 Set authentication token and login
 @param authToken user authentication token
 */
- (void)loginWithAuthToken:(nonnull NSString *)authToken;

/**
 Update authentication token and login
 @param authToken user authentication token
 */
- (void)refreshAuthToken:(nonnull NSString *)authToken;

/**
Logout
 */
- (void)logout;

#pragma mark - Conversation

/**
 Get a conversation object by id
 @param converesationId     conversation id
 @param completion          completion block
 */
- (void)getConversationWithId:(nonnull NSString *)converesationId
                   completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion;


/**
 Creatw a new conversation with name

 @param name                conversation name
 @param completion          completion block
 */
- (void)createConversationWithName:(nonnull NSString *)name completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion;

#pragma mark - Call

///**
// Creatw a new call to users
//
// @param users           user ids to call
// @param delegate        call delegate
// @param completion      completion block
// */

- (void)callToUsers:(nonnull NSArray<NSString *>*)users
           delegate:(nullable id<NXMCallDelegate>)delegate
         completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion;


#pragma mark - Push Notifications

/**
 Enable push notification for specific device

 @param deviceToken     the device token
 @param isPushKit       is the app using PushKit
 @param isSandbox       is apple sandbox enviroment
 @param completion      completion block
 */
- (void)enablePushNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
                                     isPushKit:(BOOL)isPushKit
                                     isSandbox:(BOOL)isSandbox
                                    completion:(void(^_Nullable)(NSError * _Nullable error))completion;

/**
 Disable push notification for the current device
 
 @param completion      completion block
 */
- (void)disablePushNotificationsWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion;

/**
 Call this method on incoming push

 @param userInfo    pushInfo
 @return true if stitch push
 */
- (BOOL)isStitchPushWithUserInfo:(nonnull NSDictionary *)userInfo;

/**
 Handle stitch push
 Call this method when isStitchPushWithUserInfo:userInfo return true
 
 @param userInfo    pushInfo
 @param completion  completion block
 */
- (void)processStitchPushWithUserInfo:(nonnull NSDictionary *)userInfo
                           completion:(void(^_Nullable)(NSError * _Nullable error))completion;
@end
