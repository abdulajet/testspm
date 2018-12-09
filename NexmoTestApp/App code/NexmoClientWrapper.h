//
//  NexmoClientWrapper.h
//  NexmoTestApp
//
//  Created by Chen Lev on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StitchClient/StitchClient.h>

@interface NexmoClientWrapper : NSObject <NXMStitchClientDelegate>

@property (nonatomic, nonnull, readonly) NXMStitchClient *client;

+ (nonnull NexmoClientWrapper *)sharedInstance;

@end

