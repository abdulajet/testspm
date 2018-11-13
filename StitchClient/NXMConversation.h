//
//  NXMConversation.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StitchCore/StitchCore.h>

#import "NXMConversationDelegate.h"
#import "NXMConversationEventsController.h"
#import "NXMConversationMembersController.h"

typedef NS_ENUM(NSInteger, NXMAttachmentType) {
    NXMAttachmentTypeImage
};

@interface NXMConversation : NSObject

@property (readonly, nonatomic, nonnull) NSString *conversationId;
@property (readonly, nonatomic, nonnull) NSString *name;
@property (readonly, nonatomic, nullable) NSString *displayName;
@property (readonly, nonatomic) NSInteger lastEventId;
@property (readonly, nonatomic, nonnull) NSDate *creationDate;
@property (readonly, nonatomic, nullable) NXMMember *myMember;

- (void)setDelegate:(nonnull NSObject<NXMConversationDelegate> *)delegate;

- (void)joinWithCompletion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion;

- (void)addMemberWithUserId:(nonnull NSString *)userId
                completion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion;

- (void)removeMemberWithMemberId:(nonnull NSString *)memberId
                     completion:(void (^_Nullable)(NSError * _Nullable error))completion;

- (void)sendText:(nonnull NSString *)text
     completion:(void (^_Nullable)(NSError * _Nullable error))completion;

- (void)sendAttachmentOfType:(NXMAttachmentType)attachmentType
                   WithName:(nonnull NSString *)name
                        data:(nonnull NSData *)data
                  completion:(void (^_Nullable)(NSError * _Nullable error))completion;

- (nonnull NXMConversationEventsController *)eventsControllerWithTypes:(nonnull NSSet<NSNumber *> *)eventTypes
                                                          andDelegate:(id <NXMConversationEventsControllerDelegate>_Nullable)delegate;

- (nonnull NXMConversationMembersController *)membersControllerWithDelegate:(id <NXMConversationMembersControllerDelegate> _Nullable)delegate;

@end
