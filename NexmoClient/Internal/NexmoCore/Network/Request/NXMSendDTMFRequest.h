//
//  NXMSendDTMFRequest.h
//  NXMiOSSDK
//
//  Created by Assaf Passal on 8/7/19.
//  Copyright © 2019 Vonage. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NXMBaseRequest.h"

@interface NXMSendDTMFRequest : NXMBaseRequest

@property (nonatomic, nonnull) NSString *conversationId;
@property (nonatomic, nonnull) NSString *memberId;
@property (nonatomic, nonnull) NSString *digit;

- (nullable instancetype)initWithConversationId:(nonnull NSString *)conversationId
                                       memberId:(nonnull NSString *)memberId
                                          digit:(nonnull NSString *)digit;
@end
