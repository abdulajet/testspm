//
//  NXMInvitePstnKnockingRequest.h
//  Stitch_iOS
//
//  Created by Assaf Passal on 7/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//
#import "NXMBaseRequest.h"

@interface NXMInvitePstnKnockingRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *phoneNumber;
@property (nonatomic, strong, nonnull) NSString *userName;

- (nullable instancetype)initWithUserName:(nonnull NSString *)userName andPhoneNumber:(nonnull NSString*)phoneNumber;

@end
