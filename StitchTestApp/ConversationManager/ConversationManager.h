//
//  StitchWrapper.h
//  StitchTestApp
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <StitchCore/StitchCore.h>

#import "OngoingMediaCollection.h"
#import "OngoingMedia.h"


@interface ConversationManager : NSObject <NXMStitchCoreDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, readonly, strong) NXMStitchCore *stitchConversationClient;
@property (nonatomic, readwrite, strong) NSMutableDictionary *conversationIdToMemberId;
@property (nonatomic, readonly, strong, nullable) NXMUser *connectedUser;
@property (nonatomic, strong) OngoingMediaCollection *ongoingCalls;
@property NSMutableDictionary<NSString *,NSString *> * memberIdToName;



-(instancetype)initWithStitchCoreClient:(NXMStitchCore *)stitchCoreClient;
+(instancetype)sharedInstance;

-(void)setStitchCoreClient:(NXMStitchCore *)stitchCoreClient;
-(void)addLookupMemberId:(NSString *)memberId forUser:(NSString *)userId inConversation:(NSString *)conversationId;
-(bool)isCurrentUserThisMember:(NSString *)memberId;
@end

