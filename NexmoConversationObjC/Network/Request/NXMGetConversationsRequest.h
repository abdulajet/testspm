//
//  NXMGetConversationsRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMGetConversationsRequest_h
#define NXMGetConversationsRequest_h

#import "NXMBaseRequest.h"

@interface NXMGetConversationsRequest : NXMBaseRequest

@property (nonatomic, strong, nullable) NSString *name;
@property (nonatomic, strong, nullable) NSString *dateStart;
@property (nonatomic, strong, nullable) NSString *dateEnd;
@property (nonatomic, strong, nullable) NSString *order;
@property long pageSize;
@property long recordIndex;

@end

#endif /* NXMGetConversationsRequest_h */
