//
//  NXMConversation.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMConversationDelegate.h"
#import "NXMConversationEventsController.h"
#import "NXMMember.h"

typedef NS_ENUM(NSInteger, NXMAttachmentType) {
    NXMAttachmentTypeImage
};

/*!
 @interface NXMConversation
 @brief The NXMConversation object represent a conversation.
 @discussion NXMConversation can be used for messaging and media.
 */
@interface NXMConversation : NSObject

/// Conversation unique identifier.
@property (readonly, nonatomic, nonnull) NSString *conversationId;

/// Conversation unique name.
@property (readonly, nonatomic, nonnull) NSString *name;

/// Conversation display name.
@property (readonly, nonatomic, nullable) NSString *displayName;
@property (readonly, nonatomic) NSInteger lastEventId;

/// Conversation creation date
@property (readonly, nonatomic, nonnull) NSDate *creationDate;

/// The current user member
@property (readonly, nonatomic, nullable) NXMMember *myMember;

/// Conversation all members
@property (readonly, nonatomic, nullable) NSArray<NXMMember *> *allMembers;

/// Conversation events delegate
@property (nonatomic, weak, nullable) id <NXMConversationDelegate> delegate;

/// Conversation updates delegate
@property (nonatomic, weak, nullable) id <NXMConversationUpdatesDelegate> updatesDelegate;

/*!
 * @brief Join the current user as a member of the conversation
 * @param completion A block with two params an NSError if one occured and NXMMember
 * @code [conversation joinWithCompletion:^(NSError error, NXMMember member){
 if (!error) {
 NSLog(@"join the conversation failed");
 return;
 }
 
 NSLog(@"joined the conversation");
 }];
 */
- (void)joinWithCompletion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion;

/*!
 * @brief Join a specific user as a member of the conversation
 * @param username the user identifier
 * @param completion A block with two params NSError if one occured and NXMMember
 * @code [conversation joinMemberWithUsername:theUsername :^(NSError error, NXMMember member){
     if (!error) {
     NSLog(@"join the conversation failed");
     return;
     }
 
     NSLog(@"theUserId joined the conversation");
     }];
*/
- (void)joinMemberWithUsername:(nonnull NSString *)username
                completion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion;


/*!
 * @brief Current user's member leaves the conversation
 * @param completion A completion block with an error object if one occured
 * @code [conversation leaveWithCompletion:theUserId :^(NSError error, NXMMember member){
 if (!error) {
 NSLog(@"leave the conversation failed");
 return;
 }
 
 NSLog(@"Current user's member left the conversation");
 }];
 */
- (void)leaveWithCompletion:(void (^_Nullable)(NSError * _Nullable error))completion;


/**
 Kicks a member from participating in the conversation
 
 @param memberId
 The id of the member to kick
 
 @param completion
 A completion block with an error object if one occured
 */
- (void)kickMemberWithMemberId:(nonnull NSString *)memberId
                     completion:(void (^_Nullable)(NSError * _Nullable error))completion;

/**
 Send a custom event in the conversation
 
 @param customType
 The customType name
 
 @param data
 The custom event data
 
 @param completion
 A completion block with an error object if one occured
 */
- (void)sendCustomEvent:(nonnull NSString *)customType
                   data:(nonnull NSDictionary *)data
             completion:(void (^_Nullable)(NSError * _Nullable error))completion;

/**
 Sends a text message to the members of the conversation
 
 @param text
 The text to send
 
 @param completion
 A completion block with an error object if one occured
 */
- (void)sendText:(nonnull NSString *)text
     completion:(void (^_Nullable)(NSError * _Nullable error))completion;


/**
 Sends an attachment message to the members of the conversation
 
 @param attachmentType
 The type of the attachment following NXMAttachmentType enum
 
 @param name
 A name identifier of the attachment
 
 @param data
 The data of the attachment in a NSData representation
 
 @param completion
 A completion block with an error object if one occured
 */
- (void)sendAttachmentOfType:(NXMAttachmentType)attachmentType
                   WithName:(nonnull NSString *)name
                        data:(nonnull NSData *)data
                  completion:(void (^_Nullable)(NSError * _Nullable error))completion;

/**
  Sends an indication that the current user's member has seen a message
 
 @param messageId
 The message identifier of the message that has been seen by the current user
 
 @param completion
 A completion block with an error object if one occured
 */

- (void)sendMarkAsSeen:(NSInteger)messageId
            completion:(void (^_Nullable)(NSError * _Nullable error))completion;

/**
 Sends an indication that the current user's member started typing
 
 @param completion
 A completion block with an error object if one occured
 */
- (void)sendStartTypingWithCompletion:(void (^_Nullable)(NSError * _Nullable error))completion;


/**
 Sends an indication that the current user's member stopped typing
 
 @param completion
 A completion block with an error object if one occured
 */
- (void)sendStopTypingWithCompletion:(void (^_Nullable)(NSError * _Nullable error))completion;


/**
 Get an instance of NXMConversationEventsController.
 
 @param eventTypes
 A NSSet of the types of events the controller should handle

 @param delegate
 An instance conforming to the NXMConversationEventsControllerDelegate protocol, used to get notifications about changes in the controller.
 
 @return a new instance of NXMConversationEventsController
 */
- (nonnull NXMConversationEventsController *)eventsControllerWithTypes:(nonnull NSSet *)eventTypes
                                                          andDelegate:(id <NXMConversationEventsControllerDelegate>_Nullable)delegate;
@end
