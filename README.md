# Stitch - Nexmo's Mobile SDK for iOS
[![Platforms](https://img.shields.io/badge/platform-ios%7Cosx-lightgrey.svg)]()
[![CocoaPods](https://img.shields.io/badge/podspec-v0.1-blue.svg)]()

## Setup

To get started with the Stitch SDK for iOS, check out the [Stitch Mobile Developer Guide for iOS](devral-linkurl)

To use the Stitch SDK for iOS, you will need the following installed:

* Xcode 9.4 or later
* iOS 10 or later

There are two ways to import the Stitch SDK for iOS into your project:

* [CocoaPods](https://cocoapods.org/) - version 1.3 or later
* [Dynamic Frameworks](devral-linkurl)

### CocoaPods

1. Open your project's `PodFile` or create a plain text file named `Podfile` in your project if you don't have one
2. Add the following Nexmo repository as a source in the top of the file

   ```ruby
   source 'git@github.com:Vonage/NexmoCocoaPodSpecs.git'
   ```

3. Replace `TargetName` with your actual target name.

   ```ruby
   target 'TargetName' do
       pod 'StitchClient'
   end
   ```

4. Install the Pod by opening terminal and running the following command:

   ```ruby
   $ cd 'Project Dir'
   $ pod install
   ```
   where `Project Dir` is the path to the parent directory of the `PodFile`

### Frameworks
Download the stitch SDK and add it to your project

## Getting Started with Swift
TBA


## Getting Started with Objective-C
As part of the authentication process, the stitch client requires a jwt token with the [proper credentials](devral-linkurlTo_application_users_jwt).  
For ease of access, we advise to set up a Web Service to generate a unique Identity Token for each user on request.

### Login
Create a NXMStitchClient object and login with a token.

```objective-c
    NXMStitchClient *stitchClient = [NXMStitchClient new];
    [stitchClient setDelegate:self];
    [stitchClient loginWithAuthToken:@"your token"];
```
where `"your token"` is the string format of the jwt for the user you wish to log in.  
**Note:** self should implement the `NXMStitchClientDelegate` protocol.  
At the end of a succesfull login process, The following delegate method is called with isLoggedIn = true, now you can use the stitch client.

```objective-c
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;
```
if an error occured, isLoggedIn = false, and more details about the error are present in the error object.

### Logout
Logout using the stitch client.
```objective-c
    [stitchClient logout];
```
**Note:**  At the end of a succesfull logout the loginstatuschanged method is called with isLoggedIn = false. If an error occured, isLoggedIn = true, and more details about the error are present in the error object.

### Get current user info

```objective-c
    NXMUser *user = stitchClient.user;
```
**Note:** this method returns nil if no user is currently logged in.

## Media

### Create IP-IP call
IP-IP calls are done by supplying an array of userIds to call, and a delegate object implementing the `NXMCallDelegate` protocol on which to receive call events.

```objective-c
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
**Note:** at the end of the call process the completion block is called. On succesfull call creation error is nil and the call object is used to perform action on the call. If an error occured details of the error will be present in the error object.  

Changes in the status of the call invoke the following delegate method.

```objective-c
- (void)statusChanged;
```

### Hangup
use the call object to hangup the call.
```objective-c
[call turnOff];
```

### Create ip-PSTN call
TBA

### Incoming call
TBA

## Conversation
A conversation is used to provide a contextual communication between users.

### Create new conversation
Use the stitchClient to create a new conversation
```objective-c
    [stitchClient createConversationWithName:@"conversation name" completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
            if(error) {
                //Handle error
                return;
            }

       //Do Something with the conversation     
    }];
```

**Note:**
* `"conversation name"` should be unique with regards to the scope of your application_id.  
* At the end of this Async request, the completion block is invoked with an NXMConversation object if the conversation was created, or an error object if something went wrong.
* The conversation identifier is needed to query this conversation at a later time
  ```objective-c
  NSString* conv_id = conversation.conversationId;
  ```


### Get existing conversation
Getting an existing conversation using a conversation identifier
```objective-c
    [stitchClient getConversationWithId:@"conversation identifier" completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
            if(error) {
                //Handle error
                return;
            }

       //Do Something with the conversation     
    }];
```
**Note:** At the end of this Async request, the completion block is invoked with an NXMConversation object if the conversation was created, or an error object if something went wrong.

### Get all conversations
TBA 

### Joining a conversation
Join to a conversation to be a member of the conversation and have the ability to send and receive messages and other conversation related information.
```objective-c
[conversation joinWithCompletion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
            if(error) {
                //Handle error
                return;
            }

       //You are now a member of this conversation     
    }];
```

### Add a user to a conversation
Add other users as members of this conversation for them to send and receive messages as well.
```objective-c
[conversation addMemberWithUserId:@"user id" completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
            if(error) {
                //Handle error
                return;
            }

       //user was added to this conversation
    }];
```

## Get conversation members (Member Controller)
A conversations' Member Controller allows for a realtime updated information regarding the members of this conversation.  
* Use membersControllerWithDelegate to get a Member Controller for a conversation.
  ```objective-c
  NXMConversationMembersController *membersController = [conversation membersControllerWithDelegate:NXMConversationMembersControllerDelegateImp];
  ```
  where NXMConversationMembersControllerDelegateImp implements the NXMConversationMembersControllerDelegate protocol.

* Get current users' member
  ```objective-c
  NXMMember *myMember = membersController.myMember;
  ```

* Get other members of this conversation
  ```objective-c
  NSSet<NXMMember *> *otherMembers = membersController.otherMembers;
  ```

* Get live updates regarding the members in your delegate object
  The following three methods are used to report changes to the members of the conversation
  ```objective-c
  -(void)nxmConversationMembersControllerWillChangeContent:(NXMConversationMembersController * _Nonnull)controller;
  ```
  Invoked when the controller is about to update otherMembers set or myMember. A number of changes might occur after the invocation of this method.

  ```objective-c
  -(void)nxmConversationMembersControllerDidChangeContent:(NXMConversationMembersController * _Nonnull)controller;
  ```
  Invoked when the controller is finished updating otherMembers set or myMember. A number of changes might have occured before the invocation of this method.

  ```objective-c
  -(void)nxmConversationMembersController:(NXMConversationMembersController * _Nonnull)controller didChangeMember:(nonnull NXMMember *)member forChangeType:(NXMMembersControllerChangeType)type;
  ```
  Invoked on each change to a member either in the otherMembers set or in myMember, with the type of change indicated by the NXMMembersControllerChangeType enum.
  
  **Note:** changes to the members in this controller are done on the main thread, so it is safe to use this controller directly to update the UI.
  
### Send message
call this method to send a text message

### Send attachment
TBA

### Typing indicator
TBA

## Events Controller
TBA

### Sending startTyping/stopTyping for current member:
TBA

## Push notifications
TBA


