//
//  NXMDeleteMemberRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMBaseRequest.h"

@interface NXMRemoveMemberRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *memberID;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationID andMemberId:(nonnull NSString *)memberID;

@end

