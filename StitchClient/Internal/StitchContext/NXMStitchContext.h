//
//  NXMStitchContext.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StitchCore/StitchCore.h>

#import "NXMEventsDispatcher.h"
#import "NXMStitchContextDelegate.h"

@interface NXMStitchContext : NSObject<NXMStitchCoreDelegate>
@property (readonly, nonatomic, nonnull) NXMStitchCore *coreClient;
@property (readonly, nonatomic, nonnull) NXMEventsDispatcher *eventsDispatcher;
@property (readonly, nonatomic, nullable) NXMUser *currentUser;

-(void)setDelegate:(NSObject<NXMStitchContextDelegate> * _Nonnull)stitchContextDelegate;
-(instancetype)initWithCoreClient:(nonnull NXMStitchCore *)coreClient;
@end
