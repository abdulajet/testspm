//
//  NXMStitchContext.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMEventsDispatcher.h"
#import "NXMStitchContextDelegate.h"
#import "NXMStitchContextDelegate.h"

#import "NXMCore.h"

@interface NXMStitchContext : NSObject<NXMCoreDelegate>
@property (readonly, nonatomic, nonnull) NXMCore *coreClient;
@property (readonly, nonatomic, nonnull) NXMEventsDispatcher *eventsDispatcher;
@property (readonly, nonatomic, nullable) NXMUser *currentUser;

-(void)setDelegate:(NSObject<NXMStitchContextDelegate> * _Nonnull)stitchContextDelegate;
-(instancetype)initWithCoreClient:(nonnull NXMCore *)coreClient;
@end
 
