//
//  NXMMemberParser.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMMember.h"
#import "NXMMemberEvent.h"
#import "NXMEnums.h"

@interface NXMMember (PrivateParser)

- (nullable instancetype)initWithData:(NSDictionary *)data
                 andMemberIdFieldName:(NSString *)memberIdFieldName;

- (nullable instancetype)initWithData:(NSDictionary *)data
                 andMemberIdFieldName:(NSString *)memberIdFieldName
                    andConversationId:(NSString *)convertaionId;

- (nullable instancetype)initWithMemberEvent:(NXMMemberEvent *)memberEvent;

- (void)updateChannelWithLeg:(NXMLeg *)leg;
- (void)updateMedia:(NXMMediaSettings *)media;
- (void)updateState:(NXMMemberState)state time:(NSDate *)time initiator:(NSString *)initiator;
- (void)updateExpired;
@end
