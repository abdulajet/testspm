//
//  AppDelegate.h
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NexmoConversationObjC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NXMConversationClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly, strong) StitchConversationClientCore *stitchConversation;

- (void)setStitch:(StitchConversationClientCore *)stitch;
- (void)addConversationMember:(NSString *)conv  memberId:(NSString *)memberId;

@end

