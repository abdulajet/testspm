//
//  NXMDeleteMemberRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMRemoveMemberRequest_h
#define NXMRemoveMemberRequest_h
#import "NXMBaseRequest.h"

@interface NXMRemoveMemberRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *memberID;

@end



#endif /* NXMRemoveMemberRequest_h */
