//
//  NXMConversation.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationDelegate.h"
#import "NXMMember.h"
#import "NXMEventsPage.h"

/**
 * A list of attachment types for an `NXMConversation`.
 */
typedef NS_ENUM(NSInteger, NXMAttachmentType) {
    /// An Image attachment type
    NXMAttachmentTypeImage
};

/**
 The NXMConversation object represent a conversation.
 @see NXMConversation can be used for messaging and media.
 */
@interface NXMConversation : NSObject

/// Conversation unique identifier.
@property (readonly, nonatomic, nonnull) NSString *uuid;

/// Conversation unique name.
@property (readonly, nonatomic, nonnull) NSString *name;

/// Conversation display name.
@property (readonly, nonatomic, nullable) NSString *displayName;

/// ID of the last event on the conversation.
@property (readonly, nonatomic) NSInteger lastEventId;

/// Conversation creation date.
@property (readonly, nonatomic, nonnull) NSDate *creationDate;

/// The current user member.
@property (readonly, nonatomic, nullable) NXMMember *myMember;

/// Conversation all members.
@property (readonly, nonatomic, nonnull) NSArray<NXMMember *> *allMembers;

/// Conversation events delegate.
@property (nonatomic, weak, nullable) id <NXMConversationDelegate> delegate;

/// Conversation updates delegate.
@property (nonatomic, weak, nullable) id <NXMConversationUpdateDelegate> updatesDelegate;

/**
 * Invite a user as a member of the conversation with a username.
 * @param username The username of the user to invite.
 * @param completion A block with param NSError if one occurred.
 * @code [conversation inviteMemberWithUsername:username completion:^(NSError error){
 if (!error) {
 NSLog(@"invited username to the conversation failed");
 return;
 }
 
 NSLog(@"invited username the conversation");
 }];
 */
- (void)inviteMemberWithUsername:(nonnull NSString *)username
                      completion:(void (^_Nullable)(NSError * _Nullable error))completion;

/**
 * Join the current user as a member of the conversation.
 * @param completionHandler A block with two params an NSError if one occurred and NXMMember.
 * @code [conversation joinWithCompletion:^(NSError error, NXMMember member){
 if (!error) {
 NSLog(@"join the conversation failed");
 return;
 }
 
 NSLog(@"joined the conversation");
 }];
 */
- (void)join:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completionHandler;

/**
 * Join a specific user as a member of the conversation.
 * @param username The username of the user to join the conversation.
 * @param completion A block with two params NSError if one occurred and NXMMember.
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


/**
 * Leaves the conversation.
 * @param completionHandler A completion block with an error object if one occurred.
 * @code [conversation leave:theUserId :^(NSError error, NXMMember member){
 if (!error) {
 NSLog(@"leave the conversation failed");
 return;
 }
 
 NSLog(@"Current user's member left the conversation");
 }];
 */
- (void)leave:(void (^_Nullable)(NSError * _Nullable error))completionHandler;


/**
 Kicks a member from participating in the conversation.
 @param memberId The id of the member to kick.
 @param completion A completion block with an error object if one occurred.
 */
- (void)kickMemberWithMemberId:(nonnull NSString *)memberId
                     completion:(void (^_Nullable)(NSError * _Nullable error))completion;

 /// Enable media for the current user member.
- (void)enableMedia;

/// Disable media for the current user member.
- (void)disableMedia;

/**
 Send a custom event in the conversation.
 @param customType The customType name.
 @param data The custom event data.
 @param completionHandler A completion block with an error object if one occurred.
 */
- (void)sendCustomWithEvent:(nonnull NSString *)customType
                       data:(nonnull NSDictionary *)data
          completionHandler:(void (^_Nullable)(NSError * _Nullable error))completionHandler;

/**
 Sends a text message to the members of the conversation.
 @param text The text to send.
 @param completionHandler A completion block with an error object if one occurred.
 */
- (void)sendText:(nonnull NSString *)text
     completionHandler:(void (^_Nullable)(NSError * _Nullable error))completionHandler;


/**
 Sends an attachment message to the members of the conversation.
 @param type The type of the attachment following NXMAttachmentType enum.
 @param name A name identifier of the attachment.
 @param data The data of the attachment in a NSData representation.
 @param completionHandler A completion block with an error object if one occurred.
 */
- (void)sendAttachmentWithType:(NXMAttachmentType)type
                          name:(nonnull NSString *)name
                          data:(nonnull NSData *)data
             completionHandler:(void (^_Nullable)(NSError * _Nullable error))completionHandler;

/**
 Sends an indication that the current user's member has seen a message.
 @param message The message identifier of the message that has been seen by the current user.
 @param completionHandler A completion block with an error object if one occurred.
 */

- (void)sendMarkSeenMessage:(NSInteger)message
          completionHandler:(void (^_Nullable)(NSError * _Nullable error))completionHandler;

/**
 Sends an indication that the current user's member started typing.
 @param completionHandler A completion block with an error object if one occurred.
 */
- (void)sendStartTyping:(void (^_Nullable)(NSError * _Nullable error))completionHandler;


/**
 Sends an indication that the current user's member stopped typing.
 @param completionHandler A completion block with an error object if one occurred.
 */
- (void)sendStopTyping:(void (^_Nullable)(NSError * _Nullable error))completionHandler;

/**
 * Get conversation events page with 10 elements page size and ascending order.
 * @param completionHandler  A completion block with an error object if one occurred.
 */
- (void)getEventsPage:(void (^_Nullable)(NSError * _Nullable error, NXMEventsPage * _Nullable events))completionHandler;

/**
 * Get conversation events page.
 * @param size The page size.
 * @param order The page order as an `NXMPageOrder`.
 * @param completionHandler  A completion block with an error object if one occurred.
 */
- (void)getEventsPageWithSize:(NSUInteger)size
                        order:(NXMPageOrder)order
            completionHandler:(void (^_Nullable)(NSError * _Nullable error, NXMEventsPage * _Nullable events))completionHandler;

/**
 * Get conversation events page.
 * @param size The page size.
 * @param order The page order as an `NXMPageOrder`.
 * @param eventType The event type filter.
 * @param completionHandler  A completion block with an error object if one occurred.
 */
- (void)getEventsPageWithSize:(NSUInteger)size
                        order:(NXMPageOrder)order
                    eventType:(nullable NSString *)eventType
            completionHandler:(void (^_Nullable)(NSError * _Nullable error, NXMEventsPage * _Nullable events))completionHandler;

@end
