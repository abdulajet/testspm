//
//  StitchWrapper.h
//  StitchTestApp
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "OngoingMediaCollection.h"
#import "OngoingMedia.h"

#import "StitchCore.h"

@interface ConversationManager : NSObject <NXMConversationCoreDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, readonly, strong) NXMConversationCore *stitchConversationClient;
@property (nonatomic, readwrite, strong) NSMutableDictionary *conversationIdToMemberId;
@property (nonatomic, readonly, strong, nullable) NXMUser *connectedUser;
@property (nonatomic, strong) OngoingMediaCollection *ongoingCalls;
@property NSMutableDictionary<NSString *,NSString *> * memberIdToName;



-(instancetype)initWithStitchCoreClient:(NXMConversationCore *)stitchCoreClient;
+(instancetype)sharedInstance;

-(void)setStitchCoreClient:(NXMConversationCore *)stitchCoreClient;
-(void)addLookupMemberId:(NSString *)memberId forUser:(NSString *)userId inConversation:(NSString *)conversationId;
-(bool)isCurrentUserThisMember:(NSString *)memberId;
@end

