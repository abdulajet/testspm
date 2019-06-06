//
//  NXMChannelPrivate.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//
#import "NXMChannel.h"

@interface NXMDirection (PrivateParser)

- (nullable instancetype)initWithType:(NXMDirectionType)type
                              andData:(NSString *)data;

@end

@interface NXMChannel (PrivateParser)

- (nullable instancetype)initWithData:(NSDictionary *)data
                    andConversationId:(NSString *)conversationId
                          andMemberId:(NSString *)memberId;

- (void)addLeg:(NXMLeg *)leg;

@end

