//
//  NXMMembersController.h
//  StitchObjC
//
//  Created by Doron Biaz on 10/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationEventsQueue.h"

@class NXMUser;
@class NXMMember;
@class NXMConversation;
@class NXMConversationMembersController;
typedef NS_ENUM(NSInteger, NXMMembersControllerChangeType){
    NXMMembersControllerChangeTypeAdded,
    NXMMembersControllerChangeTypeRemoved
};

@protocol NXMConversationMembersControllerDelegate <NSObject>
@optional
-(void)nxmConversationMembersControllerWillChangeContent:(NXMConversationMembersController * _Nonnull)controller;
-(void)nxmConversationMembersControllerDidChangeContent:(NXMConversationMembersController * _Nonnull)controller;
-(void)nxmConversationMembersController:(NXMConversationMembersController * _Nonnull)controller didChangeMember:(nonnull NXMMember *)member forChangeType:(NXMMembersControllerChangeType)type;
@end

@interface NXMConversationMembersController : NSObject<NXMConversationEventsQueueDelegate>
@property (nonatomic, readonly, nullable) NXMMember *myMember;
@property (nonatomic, readonly, nullable) NSSet<NXMMember *> *otherMembers;
@property (nonatomic, readonly, nullable, weak) id <NXMConversationMembersControllerDelegate> delegate;

-(nullable NXMMember *)memberForMemberId:(nonnull NSString *)memberId;
@end
