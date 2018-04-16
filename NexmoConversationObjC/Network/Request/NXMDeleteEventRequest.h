//
//  NXMDeleteTextRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMDeleteEventRequest_h
#define NXMDeleteEventRequest_h

#import "NXMBaseRequest.h"

@interface NXMDeleteEventRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *memberID;
@property (nonatomic, strong, nonnull) NSString *eventID;

@end


#endif /* NXMDeleteTextRequest_h */
