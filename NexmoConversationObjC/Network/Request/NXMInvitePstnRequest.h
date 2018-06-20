//
//  NXMInvitePstnRequest.h
//  NexmoConversationObjC
//
//  Created by user on 12/06/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMBaseRequest.h"

@interface NXMInvitePstnRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *userID;
@property (nonatomic, strong, nonnull) NSString *phoneNumber;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationID andUserID:(nonnull NSString *)userID andPhoneNumber:(nonnull NSString*)phoneNumber;

@end
