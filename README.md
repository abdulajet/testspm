# Nexmo's Mobile SDK for iOS
[![Platforms](https://img.shields.io/badge/platform-ios%7Cosx-lightgrey.svg)]()
[![CocoaPods](https://img.shields.io/badge/podspec-v0.1-blue.svg)]()

## Setup

To get started with the nexmo SDK for iOS, check out the [nexmo Mobile Developer Guide for iOS](https://developer.nexmo.com/)

To use the nexmo SDK for iOS, you will need the following installed:

* Xcode 9.4 or later
* iOS 10 or later

There are two ways to import the nexmo SDK for iOS into your project:

* [CocoaPods](https://cocoapods.org/) - version 1.3 or later
* [Dynamic Frameworks](devral-linkurl)

### CocoaPods

1. Open your project's `PodFile` or create a plain text file named `Podfile` in your project if you don't have one

2. Replace `TargetName` with your actual target name.

   ```ruby
   target 'TargetName' do
       pod 'NexmoClient'
   end
   ```

4. Install the Pod by opening terminal and running the following command:

   ```ruby
   $ cd 'Project Dir'
   $ pod install
   ```
   where `Project Dir` is the path to the parent directory of the `PodFile`

To use the SDK, add the following: 
Swift: import NexmoClient 
Objective-c: #import <NexmoClient/NexmoClient.h>; 

### Frameworks
Download the Nexmo SDK and add it to your project


## Getting Started with Swift
TBA


## Getting Started with Objective-C
As part of the authentication process, the nexmo client requires a jwt token with the [proper credentials](https://developer.nexmo.com/messages/building-blocks/before-you-begin).  
For ease of access, we advise to set up a Web Service to generate a unique Identity Token for each user on request.

### Login
Create a NXMClient object and login with a token.

```objective-c
    NXMClient *client = [NXMClient new];
    [client setDelegate:self];
    [client loginWithAuthToken:@"your token"];
```
where `"your token"` is the string format of the jwt for the user you wish to log in.  
**Note:** self should implement the `NXMClientDelegate` protocol.  
At the end of a succesfull login process, The following delegate method is called with isLoggedIn = true, now you can use the client.

```objective-c
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;
```
if an error occured, isLoggedIn = false, and more details about the error are present in the error object.

### Logout
Logout using the nexmo client.
```objective-c
    [client logout];
```
**Note:**  At the end of a succesfull logout the loginstatuschanged method is called with isLoggedIn = false. If an error occured, isLoggedIn = true, and more details about the error are present in the error object.

### Get current user info

```objective-c
    NXMUser *user = client.user;
```
**Note:** this method returns nil if no user is currently logged in.


## License

Copyright (c) 2018 Vonage. All rights reserved. Licensed only under the Nexmo SDK License Agreement (the "License") located at License file.


