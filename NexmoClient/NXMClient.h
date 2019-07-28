//
//  NXMClient.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMClientDelegate.h"
#import "NXMConversation.h"
#import "NXMCall.h"

/*!
 * @brief You use a <i>NXMClient</i> instance to utilise the services provided by NexmoConversation API in your app.
 * <p>
 * A session is the period during which your app is connected to NexmoConversation API.
 * Sessions are established for the length of time given when the authToken was created.
 * <p>
 * Tokens also have a lifetime and can optionally be one-shot which will allow a single login only, before
 * the authToken becomes invalid for another login attempt. If the authToken is revoked while a session is active the
 * session may be terminated by the server.
 * It is only possible to have a single session active over a socket.io connection at a time.
 * Session multiplexing is not supported. {@link NXMClient#InitWithToken:NSString*}</p>
 *
 * <strong>Note</strong>: The connection uses socket.io for both web and mobile clients.
 * Upon a successful socket.io connection the client needs to authenticate itself.
 * This is achieved by sending a login request via {@link NXMClient#login} and get the answer in the delegate {@link NXMCLient#setDelegate}.</p>
 *
 * <p>Unless otherwise specified, all the methods invoked by this client are executed asynchronously.</p>
 *
 * <p>For the security of your Nexmo account, you should not embed directly your NexmoConversation credential authToken as strings in the app you submit to the Google Play Store.</p>
 * <p>
 * First step is to acquire a {@link NXMClient} instance based on user credentials.
 * <p>To construct a {@link NXMClient} the required parameters are:</p>
 * <ul>
 * <li>Token:  The user specific token.</li>
 * </ul>
 * <p>
 * Im oreder to get the answer you must call {@link NXMClient#setDelegate}
 * Remember to logout when needed in order to remove current user and disconnect from the underlying connection.
 * <p>Example usage:</p>
 * <pre>
 *     myClient.logout
 * </pre>
 * <p>
 * @code [myClient.call:usernames, callHandler:NXMCallHandlerInApp delegate:self completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call)){
        if (call){
            //You got the call object
        }
 *     })];
 */


@interface NXMClient : NSObject

/*!
 * @brief Get the current connection state
 * @code NXMConnectionStatus currentConnectionStatus = [myNXNClient  getConnectionStatus];
*/
@property (nonatomic, assign, readonly, getter=getConnectionStatus) NXMConnectionStatus connectionStatus;

/*!
 * @brief Get the current user, the current user is the determine in the login by the token
 * @code NXMUser currentUser = [myNXNClient  getUser];
 */
@property (nonatomic, readonly, nullable, getter=getUser) NXMUser *user;


/*!
 * @brief Get the current user token
 * @code NSString currentToken = [myNXNClient  getToken];
 */
@property (nonatomic, readonly, nullable, getter=getToken) NSString *token;


/*!
 * @brief Set the current user token
 * @code [myNXNClient initWithToken:authToken];
 * @param authToken user authentication token
 */
- (nullable instancetype)initWithToken:(nonnull NSString *)authToken;


/*!
 * @brief Set NXMClient delegate
 * @code [myNXNClient setDelegate:clientDelegate];
 *  @param delegate a `NXMClientDelegate` object.
 */
- (void)setDelegate:(nonnull id <NXMClientDelegate>)delegate;


/*!
 * @brief login with current token the response in NXMClientDelegate:connectionStatusChanged
 * @code [myNXNClient login];
 */
- (void)login;

/*!
 * @brief Refresh the current user token
 * @code [myNXNClient refreshAuthToken:authToken];
 * @param authToken user authentication token
 */
- (void)refreshAuthToken:(nonnull NSString *)authToken;


/*!
 * @brief logout the current user, the response in NXMClientDelegate:connectionStatusChanged
 * @code [myNXNClient logout];
 */
- (void)logout;

#pragma mark - Conversation

/**
 Get a conversation object by id
 @brief getConversation With a specific Id
 @param conversationId     conversation id
 @param completion         completion block
 @code [myNXNClient getConversationWithId:conversationId completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion{
 if (!error){
        NXMConversation myConversation = conversation;
    }
 }];
 */
- (void)getConversationWithId:(nonnull NSString *)conversationId
                   completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion;


/**
 @brief Create a new conversation with specific name: it is a unique per nexmo application
 @param name                conversation name
 @param completion          completion block
 @code [myNXNClient createConversationWithName:uniqueName completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation)){
 if (!error)
 NXMConvertion myNamedConversation = convetsation;
 }];
 */
- (void)createConversationWithName:(nonnull NSString *)name completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion;

#pragma mark - Call

/**
 @brief  Create a new call to users
 @param callees         user ids/name or pstn number to call
 @param callHandler     type of the call (InApp/SERVER)
 @param delegate        call delegate
 @param completion      completion block
 @code [myNXNClient call:usernames callHandler:NXMCallHandlerInApp delegate:callDelegate completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call)){
 if (!error){
 NXMCall myCall = call;
 }];
 */
- (void)call:(nonnull NSArray<NSString *>*)callees
    callHandler:(NXMCallHandler)callHandler
    delegate:(nullable id<NXMCallDelegate>)delegate
  completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion;

#pragma mark - Push Notifications

/**
 @brief  Enable push notification for specific device
 @param deviceToken     the device token
 @param isPushKit       is the app using PushKit
 @param isSandbox       is apple sandbox enviroment
 @param completion      completion block
 @code [myNXNClient enablePushNotificationsWithDeviceToken:deviceToken isPushKit:isPushKit isSandbox:isSandbox completion:(void(^_Nullable)(NSError * _Nullable error))completion{
 }];
 */
- (void)enablePushNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
                                     isPushKit:(BOOL)isPushKit
                                     isSandbox:(BOOL)isSandbox
                                    completion:(void(^_Nullable)(NSError * _Nullable error))completion;

/**
 @brief  Disable push notification for current device
 @param completion      completion block
 @code [myNXNClient disablePushNotificationsWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion{
 }];
 */
- (void)disablePushNotificationsWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion;

/**
 @brief  Check if a push notification is a NexmoPush, Call this method on incoming push
 @param userInfo    pushInfo
 @return true if nexmo push
 @code BOOL isNexmoPush = [myNXNClient isNexmoPushWithUserInfo:userInfo];
 if (isNexmoPush){
 [myNXNClient processNexmoPushWithUserInfo:userInfo completion:(void(^_Nullable)(NSError * _Nullable error)){
 if (!error){
 NSLog(@"Process a Nexmo push");
 }];
 */
- (BOOL)isNexmoPushWithUserInfo:(nonnull NSDictionary *)userInfo;

/**
 @brief process Nexmo push, Call this method when isNexmoPushWithUserInfo:userInfo return true
 @param userInfo    pushInfo
 @param completion  completion block
 @code BOOL isNexmoPush = [myNXNClient isNexmoPushWithUserInfo:userInfo];
 if (isNexmoPush){
 [myNXNClient processNexmoPushWithUserInfo:userInfo completion:(void(^_Nullable)(NSError * _Nullable error)){
 if (!error){
 NSLog(@"Process a Nexmo push");
 }];
 */
- (void)processNexmoPushWithUserInfo:(nonnull NSDictionary *)userInfo
                           completion:(void(^_Nullable)(NSError * _Nullable error))completion;

@end
