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
@property (nonatomic, strong, nonnull) NSString *username;
@property (nonatomic) BOOL mediaEnabled;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationID username:(nonnull NSString *)username;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationID username:(nonnull NSString *)username mediaEnabled:(BOOL)mediaEnabled;

@end


