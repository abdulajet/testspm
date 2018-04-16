//
//  NXMInviteUserRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMInviteUserRequest_h
#define NXMInviteUserRequest_h
#import "NXMBaseRequest.h"

@interface NXMInviteUserRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *userID;

@end

#endif /* NXMInviteUserRequest_h */
