//
//  NXMInviteUserRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMBaseRequest.h"

@interface NXMInviteUserRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *userID;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationID andUserID:(nonnull NSString *)userID;

@end


