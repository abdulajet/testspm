//
//  NXMStitchContext.h
//  StitchObjC
//
//  Created by Doron Biaz on 9/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationCore.h"
#import "NXMEventsDispatcher.h"
#import "NXMStitchContextDelegate.h"

@interface NXMStitchContext : NSObject<NXMConversationCoreDelegate>
@property (readonly, nonatomic, nonnull) NXMConversationCore *coreClient;
@property (readonly, nonatomic, nonnull) NXMEventsDispatcher *eventsDispatcher;
@property (readonly, nonatomic, nullable) NXMUser *currentUser;

-(void)setDelegate:(NSObject<NXMStitchContextDelegate> * _Nonnull)stitchContextDelegate;
-(instancetype)initWithCoreClient:(nonnull NXMConversationCore *)coreClient;
@end
