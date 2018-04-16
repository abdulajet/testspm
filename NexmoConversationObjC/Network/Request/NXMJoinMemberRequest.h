//
//  NXMJoinMemberRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMJoinMemberRequest_h
#define NXMJoinMemberRequest_h
#import "NXMBaseRequest.h"

@interface NXMJoinMemberRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *memberID;

@end

#endif /* NXMJoinMemberRequest_h */
