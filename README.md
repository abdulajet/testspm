# Stitch Mobile Nexmo SDK for iOS
[![Platforms](https://img.shields.io/badge/platform-ios%7Cosx-lightgrey.svg)]()
[![CocoaPods](https://img.shields.io/badge/podspec-v0.1-blue.svg)]()

## Setting Up

To get started with the Stitch SDK for iOS, check out the [Stitch Mobile Developer Guide for iOS](devral-linkurl)

To use the Stitch SDK for iOS, you will need the following installed:

* Xcode 9.4 or later
* iOS 10 or later

There are two ways to import the Stitch SDK for iOS into your project:

* [CocoaPods](https://cocoapods.org/)
* [Dynamic Frameworks](devral-linkurl)

### CocoaPods 1.3 or later

Create pod plain text file named `Podfile`
Add nexmo repo source in the top of the file

```ruby
source 'git@github.com:Vonage/NexmoCocoaPodSpecs.git'
```

Replace `YourTarget` with your actual target name.

```ruby
target 'TargetName' do
    pod 'StitchClient'
end
```

Then run the following command:

```ruby
$ pod install
```

### Frameworks
Download the stitch SDK and add it to your project

## Getting Started with Swift



## Getting Started with Objective-C
As part of the Authentication process, you will need to set up a Web Service which generates a unique Identity Token for each user on request.

### Login
Create NXMStitchClient object and login.

```ruby
    NXMStitchClient *stitchClient = [NXMStitchClient new];
    [stitchClient setDelegate:self];
    [stitchClient loginWithAuthToken:@"your token"];
```

When this delegate method called with isLoggedIn = true the login done, now you can use the stitch client.

```ruby
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;
```

### Logout

```ruby
    [stitchClient logout];
```

### Get user info

```ruby
    NXMUser *user = stitchClient.user;
```

## Media

### Create ip-ip call

To create ip-ip call:
Your object should implement NXMCallDelegate
```ruby
    [stitchClient callToUsers:@[@"userId"] delegate:NXMCallDelegateImp completion:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if (error) {
            // create call failed
        }
        
        if (!call) {
            // create call failed
        }
        
        // the call created, you will get updates in the call delegate (NXMCallDelegateClass)
    }];
```

When this delegate method called you can check the call status
```ruby
- (void)statusChanged;
```

### Hangup

```ruby
[call turnOff];
```

### Create ip-PSTN call
TBA

### Incoming call

## Conversation
TBA

### Get existing conversation
TBA

### Create new conversation
TBA

### Send message
TBA

### Send attachment
TBA

### Typing indicator
TBA

## Events Controller
TBA

## Member Controller
TBA

### Sending startTyping/stopTyping for current member:
TBA

## Push notifications
TBA


