//
//  NXMConversation.h
//  StitchObjC
//
//  Created by Doron Biaz on 9/20/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationEvents.h"
#import "NXMConversationDetails.h"
#import "NXMConversationDelegate.h"
#import "NXMStitchContext.h"

@interface NXMConversation : NSObject
@property (readonly, nonatomic, nonnull) NSString *conversationId;
@property (readonly, nonatomic, nonnull) NSString *name;
@property (readonly, nonatomic, nullable) NSString *displayName;
@property (readonly, nonatomic) NSInteger lastEventId;
@property (readonly, nonatomic, nonnull) NSDate *creationDate;
@property (readonly, nonatomic, nullable) NXMMember *myMember;

-(void)setDelegate:(nonnull NSObject<NXMConversationDelegate> *)delegate;
-(void)addMemberWithUserId:(nonnull NSString *)userId completion:(void (^_Nullable)(NSError * _Nullable error))completion;
-(void)removeMemberWithMemberId:(nonnull NSString *)memberId completion:(void (^_Nullable)(NSError * _Nullable error))completion;
-(void)sendText:(nonnull NSString *)text completion:(void (^_Nullable)(NSError * _Nullable error))completion;
@end
