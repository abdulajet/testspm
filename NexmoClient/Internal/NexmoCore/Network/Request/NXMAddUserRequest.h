//
//  NXMAddUserRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMBaseRequest.h"

@interface NXMAddUserRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *username;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationID andUsername:(nonnull NSString *)username;

@end


