//
//  NXMAddUserRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMAddUserRequest_h
#define NXMAddUserRequest_h

#import "NXMBaseRequest.h"

@interface NXMAddUserRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *userID;

@end

#endif /* NXMAddUserRequest_h */
