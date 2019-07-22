//
//  NXMCustomEventInternal.h
//  NexmoClient
//
//  Created by Chen Lev on 7/21/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMCustomEvent.h"

@interface NXMCustomEvent(NXMCustomEventInternal)

- (instancetype)initWithCustomType:(NSString *)customType andData:(NSDictionary *)data;

- (instancetype)initWithCustomType:(NSString *)customType
                    conversationId:(NSString *)conversationId
                           andData:(NSDictionary *)data;

- (instancetype)initWithConversationId:(NSString *)conversationId
                            sequenceId:(NSUInteger)sequenceId
                              memberId:(NSString *)memberId
                          creationDate:(NSDate *)creationDate
                            CustomType:(NSString *)customType
                               andData:(NSString *)data;

@end
