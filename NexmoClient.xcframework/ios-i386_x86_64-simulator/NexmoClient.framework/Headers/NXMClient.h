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
#import "NXMConversationsPage.h"
#import "NXMClientConfig.h"
#import "NXMPushPayload.h"

/**
 You use a NXMClient instance to utilise the services provided by the Conversation API in your app.
 
 A session is the period during which your app is connected to NexmoConversation API. Sessions are established for the length of time given when the authToken was created.
 
 Tokens also have a lifetime and can optionally be one-shot which will allow a single login only, before
 the authToken becomes invalid for another login attempt. If the authToken is revoked while a session is active the session may be terminated by the server.
 It is only possible to have a single session active over a socket.io connection at a time.
 Session multiplexing is not supported.
 
 @note The connection uses socket.io for both web and mobile clients. Upon a successful socket.io connection the client needs to authenticate itself. This is achieved by sending a login request via `-[NXMClient loginWithAuthToken:]` and get the answer in the delegate `-[NXMClient setDelegate:]`.
 
 @warning Unless otherwise specified, all the methods invoked by this client are executed asynchronously.
 
 For the security of your Nexmo account, you should not embed directly your credentials authToken as strings in the app you submit to the App Store.
 
 Remember to logout when needed in order to remove current user and disconnect from the underlying connection. Example usage:
 
     [myClient logout];
 */
@interface NXMClient : NSObject

/**
 * Shared instance of the NXMClient object
 * @code NXMClient.shared
 */
@property (class, nonatomic, readonly, nonnull) NXMClient *shared;

/**
 * Get the current connection state
 * @code NXMConnectionStatus currentConnectionStatus = [myNXNClient  getConnectionStatus];
*/
@property (nonatomic, assign, readonly, getter=getConnectionStatus) NXMConnectionStatus connectionStatus;

/**
 * Get the current user, the current user is the determine in the login by the token
 * @code NXMUser currentUser = [myNXNClient  getUser];
 */
@property (nonatomic, readonly, nullable, getter=getUser) NXMUser *user;


/**
 * Get the current user authToken
 * @code NSString currentToken = [myNXNClient  getToken];
 */
@property (nonatomic, readonly, nullable, getter=getToken) NSString *authToken;

/**
 * Get NXMClient.shared configuration
 * @code NXMClientConfig config = NXMClient.shared.configuration;
 */
@property (nonatomic, readonly, nullable, getter=getConfiguration) NXMClientConfig *configuration;


/**
 * Set shared NXMClient configuration. Must be called before [NXMClient shared].
 * @param configuration NXMClient configuration object.
 * @code [NXMClient setConfiguration:myConfiguration];
 */
+ (void)setConfiguration:(nonnull NXMClientConfig *)configuration;

/**
 * Set NXMClient delegate
 * @param delegate a `NXMClientDelegate` object.
 * @code [myNXNClient setDelegate:clientDelegate];
 */
- (void)setDelegate:(nonnull id <NXMClientDelegate>)delegate;

/**
 * Check if the login connection status is connected
 * @return YES if connected.
 * @code [myNXNClient isConnected];
*/
- (BOOL)isConnected;

/**
 * Login with current authToken the response in NXMClientDelegate:didChangeConnectionStatus
 * @param authToken user authentication authToken
 * @code [myNXNClient loginWithAuthToken:(NSString *)authToken];
 */
- (void)loginWithAuthToken:(nonnull NSString *)authToken;

/**
 * Refresh the current user authToken
 * @code [myNXNClient refreshAuthToken:authToken];
 * @param authToken user authentication authToken
 */
- (void)updateAuthToken:(nonnull NSString *)authToken;


/**
 * Logout the current user, the response in NXMClientDelegate:didChangeConnectionStatus
 * @code [myNXNClient logout];
 */
- (void)logout;

#pragma mark - Conversation

/**
 Get a conversation object by id
 @param uuid Conversation id
 @param completionHandler A completion block with an error object if one occurred.
 @code [myNXNClient getConversationWithUuid:conversationId completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion{
 if (!error){
        NXMConversation myConversation = conversation;
    }
 }];
 */
- (void)getConversationWithUuid:(nonnull NSString *)uuid
              completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completionHandler;


/**
 Create a new conversation with specific name: it is a unique per nexmo application
 @param name Conversation name
 @param completionHandler A completion block with an error object if one occurred.
 @code [myNXNClient createConversationWithName:uniqueName completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation)){
 if (!error)
 NXMConvertion myNamedConversation = convetsation;
 }];
 */
- (void)createConversationWithName:(nonnull NSString *)name
                 completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completionHandler;


/**
 Get conversations page
 @param size Page size
 @param order Page order
 @param completionHandler A completion block with an error object if one occurred.
 @code [myNXNClient getConversationsPageWithSize:size order:pageOrder completionHandler:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
 if (!error) { NXMConversationsPage *myPage = page; }
 }];
 */
- (void)getConversationsPageWithSize:(NSInteger)size
                               order:(NXMPageOrder)order
                   completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMConversationsPage * _Nullable page))completionHandler OBJC_DEPRECATED("use getConversationsPageWithSize:(NSInteger) order:(NXMPageOrder) filter:(NSString*) completionHandler instead");

/**
 Get conversations page
 @param size Page size
 @param order Page order
 @param filter "LEFT", "INVITED" or "JOINED"
 @param completionHandler A completion block with an error object if one occurred.
 @param error something
 @param page something
 @code [myNXNClient getConversationsPageWithSize:size order:pageOrder filter:filter completionHandler:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
 if (!error) { NXMConversationsPage *myPage = page; }
 }];
 */
- (void)getConversationsPageWithSize:(NSInteger)size
                               order:(NXMPageOrder)order
                              filter:(NSString*_Nullable)filter
                   completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMConversationsPage * _Nullable page))completionHandler;


#pragma mark - Call

/**
 Create a new call to users
 @param callee The user ids/name or pstn numbers to call.
 @param callHandler The type of the call (InApp/SERVER).
 @param completionHandlerA completion block with an error object if one occurred.
 @code [myNXNClient call:usernames callHandler:NXMCallHandlerInApp delegate:callDelegate completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call)){
 if (!error){
 NXMCall myCall = call;
 }];
 */
- (void)call:(nonnull NSString *)callee
    callHandler:(NXMCallHandler)callHandler
completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completionHandler;

#pragma mark - Push Notifications

/**
 Enable push notification for specific device
 @param pushKitToken The PushKit token
 @param userNotificationToken The User Notifications token
 @param isSandbox Toggle Apple sandbox environment
 @param completionHandler A completion block with an error object if one occurred.
 @code [myNXNClient enablePushNotificationsWithDeviceToken:deviceToken isPushKit:isPushKit isSandbox:isSandbox completion:(void(^_Nullable)(NSError * _Nullable error))completion{
 }];
 */
- (void)enablePushNotificationsWithPushKitToken:(nullable NSData *)pushKitToken
                          userNotificationToken:(nullable NSData *)userNotificationToken
                                      isSandbox:(BOOL)isSandbox
                              completionHandler:(void(^_Nullable)(NSError * _Nullable error))completionHandler;

/**
 Disable push notification for current device
 @param completionHandler A completion block with an error object if one occurred.
 @code [myNXNClient disablePushNotificationsWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion{
 }];
 */
- (void)disablePushNotifications:(void(^_Nullable)(NSError * _Nullable error))completionHandler;

/**
 Check if a push notification is a NexmoPush, Call this method on incoming push
 @param userInfo The pushInfo
 @return YES if it is a nexmo push.
 @code BOOL isNexmoPush = [myNXNClient isNexmoPushWithUserInfo:userInfo];
 if (isNexmoPush){
 [myNXNClient processNexmoPushWithUserInfo:userInfo completion:(void(^_Nullable)(NSError * _Nullable error)){
 if (!error){
 NSLog(@"Process a Nexmo push");
 }];
 */
- (BOOL)isNexmoPushWithUserInfo:(nonnull NSDictionary *)userInfo;

/**
 Process Nexmo push, Call this method when `-[NXMClient isNexmoPushWithUserInfo:]` returns true
 @param userInfo The pushInfo
 @param completionHandler A completion block with an error object if one occurred.
 @code BOOL isNexmoPush = [myNXNClient isNexmoPushWithUserInfo:userInfo];
 if (isNexmoPush){
 [myNXNClient processNexmoPushWithUserInfo:userInfo completion:(void(^_Nullable)(NSError * _Nullable error)){
 if (!error){
 NSLog(@"Process a Nexmo push");
 }];
 */
- (void)processNexmoPushWithUserInfo:(nonnull NSDictionary *)userInfo
                   completionHandler:(void(^_Nullable)(NSError * _Nullable error))completionHandler __attribute((deprecated("Use processNexmoPushPayload instead.")));


/**
 Process Nexmo push, Call this method when `-[NXMClient isNexmoPushWithUserInfo:]` returns true
 @param pushInfo The pushInfo
 @code BOOL isNexmoPush = [myNXNClient isNexmoPushWithUserInfo:pushInfo];
 if (isNexmoPush){
 NXMPushPayload *pushPayload = [myNXNClient processNexmoPushPayload:pushInfo];
 if (!pushPayload){
    NSLog(@"Not a nexmo push");
    return;
 };
 */
- (nullable NXMPushPayload *)processNexmoPushPayload:(nonnull NSDictionary *)pushInfo;

@end
