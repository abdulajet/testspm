//
//  NXMSendTextRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMSendTextRequest_h
#define NXMSendTextRequest_h

#import "NXMBaseRequest.h"

@interface NXMSendTextEventRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *conversationID;
@property (nonatomic, strong, nonnull) NSString *memberID;
@property (nonatomic, strong, nonnull) NSString *textToSend;

- (nullable instancetype)initWithText:(nonnull NSString *)text conversationId:(nonnull NSString*)conversationId memberId:(nonnull NSString *)memberId;
@end

#endif /* NXMSendTextRequest_h */
