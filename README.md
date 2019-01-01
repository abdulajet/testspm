# Nexmo's Mobile SDK for iOS
[![Platforms](https://img.shields.io/badge/platform-ios%7Cosx-lightgrey.svg)]()
[![CocoaPods](https://img.shields.io/badge/podspec-v0.1-blue.svg)]()

## Setup

To get started with the nexmo SDK for iOS, check out the [nexmo Mobile Developer Guide for iOS](DevRel:LinkToiOSDocumentationOfTheSDK)

To use the nexmo SDK for iOS, you will need the following installed:

* Xcode 10 or later
* iOS 10 or later

There are two ways to import the nexmo SDK for iOS into your project:

* [CocoaPods](https://cocoapods.org/) - version 1.3 or later
* [Dynamic Frameworks](DevRel:LinkToDownloadTheLatestVersionOfTheSDK)

### CocoaPods

1. Open your project's `PodFile`

2. Under your target add the `NexmoClient` pod. Replace `TargetName` with your actual target name.

   ```ruby
   target 'TargetName' do
       pod 'NexmoClient'
   end
   ```
   * Replace `Target Name` with your project's target.
   * Make sure the pod file has the public CocoaPod specs repository source.

4. Install the Pod by opening terminal and running the following command:

   ```ruby
   $ cd 'Project Dir'
   $ pod update
   ```
   where `Project Dir` is the path to the parent directory of the `PodFile`

5. Open the `xcworkspace` with XCode and disable `bitcode` for your target.

6. In your code, import the NexmoClient library:  
    **Swift** 
    ```swift
    import NexmoClient  
    ```

    **Objective-C**
    ```objective-c
    #import <NexmoClient/NexmoClient.h>;
    ```

### Frameworks
1. Download the Nexmo SDK and add it to your project

2. Open the `xcworkspace` with XCode and disable `bitcode` for your target.

3. In your code, import the NexmoClient library:  
    **Swift** 
    ```swift
    import NexmoClient  
    ```

    **Objective-C**
    ```objective-c
    #import <NexmoClient/NexmoClient.h>;
    ```

### Permissions
1. **Audio Permissions**  
    * In your code add a request for Audio Permissions  
        **swift**:   
        ```swift
        import AVFoundation
        ```
        ```swift
        func askAudioPermissions() {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted:Bool) in
                NSLog("Allow microphone use. Response: %d", granted)
            }
        }
        ```
        **objective-c**: 
        ```objective-c
        #import <AVFoundation/AVAudioSession.h>
        ```
        ```objective-c
        - (void)askAudioPermissions {
            if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
            {
                [[AVAudioSession sharedInstance] requestRecordPermission: ^ (BOOL granted)
                {
                NSLog(@"Allow microphone use. Response: %d", granted);
                }];
            }
        }
        ```
    * In your Info.plist add a new row with 'Privacy - Microphone Usage Description' and a description for using the microphone. For example `Audio Calls`.

2. **Push Notifications** - See push integration section

## Getting Started
As part of the authentication process, the nexmo client requires a jwt token with the [proper credentials](DevRel:LinkForNDPExplanationRegardingTokensAndAuthentication).  
For ease of access, we advise to set up a Web Service to generate a unique Identity Token for each user on request.

### Login
Create a NXMClient object and login with a token.  
**Swift**
```swift
let client = NXMClient()
client.setDelegate(self)
client.login(withAuthToken: "your token")
```

**Objective-C**
```objective-c
NXMClient *client = [NXMClient new];
[client setDelegate:self];
[client loginWithAuthToken:@"your token"];
```
where `"your token"` is the string format of the jwt for the user you wish to log in.  
**Note:** self should implement the `NXMClientDelegate` protocol.  
At the end of a succesfull login process, The following delegate method is called with isLoggedIn = true, now you can use the client.

**Swift**
```swift
func loginStatusChanged(_ user: NXMUser?, loginStatus isLoggedIn: Bool, withError error: Error?)
```

**Objective-C**
```objective-c
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;
```

if an error occured, isLoggedIn = false, and more details about the error are present in the error object.

### Logout
Logout using the nexmo client.  
**Swift**
```swift
client.logout()
```

**Objective-C**
```objective-c
[client logout];
```
**Note:**  At the end of a succesfull logout the loginstatuschanged method is called with isLoggedIn = false. If an error occured, isLoggedIn = true, and more details about the error are present in the error object.

### Get current user info
**Swift**
```swift
let user = client.user
```

**Objective-C**
```objective-c
NXMUser *user = client.user;
```
**Note:** this method returns nil if no user is currently logged in.

## Push Notifications

The SDK uses push notifications to receive certain events for when the app is not active.  
To allow Nexmo to send notifications to your app, create a push certificate for your app through your Apple developer account and [upload it to the nexmo push service](DevRel:LinkHowToUploadACertificateForPushService).

### Integrating Regular Push
Nexmo push is sent silently to allow the developer control over what is presented to the user.  
To Receive silent push notifications in your app use the following steps.
1. Enable push notifications for your app.  
    * In XCode under your target, open Capabilities and enable Push Notifications
    * In XCode under your target, open Capabilities and enable background modes with remote notifications selected

2.  Register for device token  
    In your app delegate implement the following delegate method to receive a device token.  
    **Swift**
    ```objective-c
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    ```
    **Objective-C**
    ```objective-c
    - (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
    ```

3. Handle incoming push
    In your app delegate adopt the UNUserNotificationCenterDelegate  
    Implement the following delegate method and add the the code to handle an incoming push notification  
    **Swift**
    ```swift
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if(client.isNexmoPush(userInfo: userInfo)) {
            client.processNexmoPush(userInfo: userInfo) { (error: Error?) in
                //Code
            }
        }
    }
    ```

    **Objective-C**
    ```objective-c
        - (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
            if([client isNexmoPushWithUserInfo:userInfo]) {
                [client processNexmoPushWithuserInfo:userInfo completion:^(NSError * _Nullable error) {
                    //Code
                }];
            }
    }
    ```
    **note**: For the SDK to process the push properly the client should be logged in.

4. Enable nexmo push notifications through a logged in SDK client
    
    **Swift**
    ```swift
    client.enablePushNotifications(withDeviceToken: 'deviceToken', isPushKit: false, isSandbox: 'isSandbox') { (error: Error?) in 
        //Code    
    }
    ```

    **Objective-C**
    ```objective-c
    [client enablePushNotificationsWithDeviceToken:'deviceToken' isPushKit:NO isSandbox:'isSandbox' completion:^(NSError * _Nullable error) {
                    //Code
                }];
    ```

    * `'isSandbox'` is YES/true for an app using the apple sandbox push servers and NO/false for an app using the apple production push servers.  
    * `'deviceToken'` is the token received in `application:didRegisterForRemoteNotificationsWithDeviceToken:`

### Integrating Voip Push
A voip push allows for a better experience when receiving notifications including receiving notifications even when the app is terminated.  
To receive voip push notifications follow the following steps.
1. Enable voip push notifications for your app.  
    * In XCode under your target, open Capabilities and enable Push Notifications
    * In XCode under your target, open Capabilities and enable background modes with Voice over IP selected

2. Import push kit, adopt PKPushRegistryDelegate and sign to voip notifications  
    **Swift**
    ```swift
    func registerForVoIPPushes() {
        self.voipRegistry = PKPushRegistry(queue: nil)
        self.voipRegistry.delegate = self
        self.voipRegistry.desiredPushTypes = [PKPushTypeVoIP]
    }
    ```

    **Objective-C**
    ```objective-c
    - (void) registerForVoIPPushes {
        self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:nil];
        self.voipRegistry.delegate = self;
        
        // Initiate registration.
        self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    }
    ```

3. Implement the following delegate method and add the the code to handle an incoming voip push notification  
    **Swift**
    ```swift
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        if(client.isNexmoPush(userInfo: payload.dictionaryPayload)) {
            client.processNexmoPush(userInfo: payload.dictionaryPayload) { (error: Error?) in
                //Code
            }
        }
    }
    ```

    **Objective-C**
    ```objective-c
    - (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
        if([client isNexmoPushWithUserInfo: payload.dictionaryPayload]) {
            [client processNexmoPushWithUserInfo:payload.dictionaryPayload completion:^(NSError * _Nullable error) {
                //Code
            }];
        }
    }
    ```
    **note**: For the SDK to process the push properly the client should be logged in. 

4. Enable nexmo push notifications through a logged in SDK client  
    **Swift**
    ```swift
    client.enablePushNotifications(withDeviceToken: 'deviceToken', isPushKit: true, isSandbox: 'isSandbox') { (error: Error?) in 
        //Code    
    }
    ```

    **Objective-C**
    ```objective-c
    [client enablePushNotificationsWithDeviceToken:'deviceToken' isPushKit:YES isSandbox:'isSandbox' completion:^(NSError * _Nullable error) {
                    //Code
                }];
    ```
    * `'isSandbox'` is YES/true for an app using the apple sandbox push servers and NO/false for an app using the apple production push servers.  
    * `'deviceToken'` is the token received in `application:didRegisterForRemoteNotificationsWithDeviceToken:`
## License

Copyright (c) 2018 Vonage. All rights reserved. Licensed only under the Nexmo SDK License Agreement (the "License") located at License file.


