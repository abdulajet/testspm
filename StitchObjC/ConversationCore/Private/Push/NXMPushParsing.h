//
//  NXMPushParsing.h
//  StitchObjC
//
//  Created by Doron Biaz on 11/1/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NXMEvent;
@protocol NXMPushParsing <NSObject>
-(nullable NXMEvent *)parseStitchPushEventWithStitchPushInfo:(nonnull NSDictionary *)stitchPushInfo;
+(nullable NSString *)eventTypeIdentifier;
@end
