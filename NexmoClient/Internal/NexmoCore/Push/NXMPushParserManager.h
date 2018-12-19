//
//  NXMPushParser.h
//  StitchObjC
//
//  Created by Doron Biaz on 11/1/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMPushParsing.h"

// invite

@class NXMEvent;
@interface NXMPushParserManager : NSObject
+(nonnull instancetype)sharedInstance;
-(BOOL)isStitchPushWithUserInfo:(nonnull NSDictionary *)userInfo;
-(nullable NXMEvent *)parseStitchPushEventWithUserInfo:(nonnull NSDictionary *)userInfo;
@end
