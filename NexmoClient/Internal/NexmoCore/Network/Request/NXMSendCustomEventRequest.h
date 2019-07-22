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

@property (nonatomic, strong, nonnull) NSString *conversationId;
@property (nonatomic, strong, nonnull) NSString *memberId;
@property (nonatomic, strong, nonnull) NSString *customType;
@property (nonatomic, strong, nonnull) NSDictionary *body;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationId
                                       memberId:(nonnull NSString *)memberId
                                      customType:(nonnull NSString *)type
                                           body:(nonnull NSDictionary *)body;
@end

