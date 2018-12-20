//
//  IncomingCallCreator.h
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTACallCreator.h"

@class NTAUserInfo;

@interface IncomingCallCreator : NSObject <CallCreator>
- (instancetype)initWithCall:(NXMCall *)call;
@end


