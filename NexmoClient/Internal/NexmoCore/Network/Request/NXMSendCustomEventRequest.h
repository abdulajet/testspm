//
//  NXMSendCustomEventRequest.h
//  NexmoClient
//
//  Created by Chen Lev on 7/21/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMBaseRequest.h"

@interface NXMSendCustomEventRequest : NXMBaseRequest

@property (nonatomic, nonnull) NSString *conversationId;
@property (nonatomic, nonnull) NSString *memberId;
@property (nonatomic, nonnull) NSString *customType;
@property (nonatomic, nonnull) NSDictionary *body;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationId
                                       memberId:(nonnull NSString *)memberId
                                      customType:(nonnull NSString *)type
                                           body:(nonnull NSDictionary *)body;
@end

