//
//  NXMEnablePushRequest.h
//  StitchObjC
//
//  Created by Chen Lev on 7/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMBaseRequest.h"
#import "NXMEnums.h"

@interface NXMEnablePushRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSData *deviceToken;
@property (nonatomic) BOOL isSandbox;

- (nullable instancetype)initWithDeviceToken:(nonnull NSData *)deviceToken isSandbox:(BOOL)isSandbox;

@end

