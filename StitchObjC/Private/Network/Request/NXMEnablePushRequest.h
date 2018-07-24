//
//  NXMEnablePushRequest.h
//  StitchObjC
//
//  Created by Chen Lev on 7/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMBaseRequest.h"

@interface NXMEnablePushRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSData *deviceToken;

- (nullable instancetype)initWithDeviceToken:(nonnull NSData *)deviceToken;

@end

