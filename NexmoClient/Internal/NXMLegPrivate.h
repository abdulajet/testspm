//
//  NXMLegPrivate.h
//  NexmoClient
//
//  Created by Assaf Passal on 5/30/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMLeg.h"

@interface NXMLeg (private)

- (nullable instancetype) initWithConversationId:(nullable NSString *)conversationId
                                     andMemberId:(nullable NSString *)memberId
                                        andLegId:(nullable NSString *)legId
                                     andlegTypeE:(NXMLegType)legType
                                   andLegStatusE:(NXMLegStatus)legStatus
                                         andDate:(nullable NSString *)date;

- (nullable instancetype) initWithConversationId:(nullable NSString *) conversationId
                                      andMemberId:(nullable NSString *) memberId
                                         andLegId:(nullable NSString *) legId
                                       andlegType:(nullable NSString *) legType
                                     andLegStatus:(nullable NSString *) legStatus
                                          andDate:(nullable NSString *) date;

- (nullable instancetype) initWithConversationId:(nullable NSString *) conversationId
                                      andMemberId:(nullable NSString *) memberId
                                       andLegData:(nullable NSDictionary *)legData
                                          andData:(nullable NSDictionary *)data;

- (nullable instancetype) initWithData:(nullable NSDictionary *)data
                             andLegData:(nullable NSDictionary *)legData;

@end

