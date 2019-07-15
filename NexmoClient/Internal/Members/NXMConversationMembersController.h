//
//  NXMMembersController.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMMember.h"
#import "NXMConversationDetails.h"
#import "NXMUser.h"
#import "NXMCoreEvents.h"

@class NXMConversation;
@class NXMConversationMembersController;

@protocol NXMConversationMembersControllerDelegate <NSObject>
@optional
- (void)nxmConversationMembersControllerWillChangeContent:(NXMConversationMembersController * _Nonnull)controller;
- (void)nxmConversationMembersControllerDidChangeContent:(NXMConversationMembersController * _Nonnull)controller;
- (void)nxmConversationMembersController:(NXMConversationMembersController * _Nonnull)controller didChangeMember:(nonnull NXMMember *)member forChangeType:(NXMMemberUpdateType)type;
@end

@interface NXMConversationMembersController : NSObject

@property (nonatomic, readonly, nullable) NXMMember *myMember;
@property (nonatomic, readonly, nullable) NSArray<NXMMember *> *allMembers;
@property (nonatomic, readonly, nullable, weak) id <NXMConversationMembersControllerDelegate> delegate;

- (instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails
                             andCurrentUser:(nonnull NXMUser *)currentUser
                                   delegate:(id <NXMConversationMembersControllerDelegate> _Nullable)deleagte;

- (void)handleEvent:(NXMEvent*_Nonnull)event;
- (void)conversationExpired;
- (nullable NXMMember *)memberForMemberId:(nonnull NSString *)memberId;
@end
