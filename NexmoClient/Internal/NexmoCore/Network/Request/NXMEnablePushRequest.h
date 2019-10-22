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

@property (nonatomic, nullable) NSData *pushKitToken;
@property (nonatomic, nullable) NSData *userNotificationToken;
@property BOOL isSandbox;

- (nullable instancetype)initWithPushKitToken:(nullable NSData *)pushKitToken
                        userNotificationToken:(nullable NSData *)userNotificationToken
                                    isSandbox:(BOOL)isSandbox;

@end

