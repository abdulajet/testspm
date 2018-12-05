//
//  NXMTestingUtils+ConversationDetails.m
//  StitchClientTests
//
//  Created by Doron Biaz on 11/29/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMTestingUtils+ConversationDetails.h"

@implementation NXMTestingUtils (ConversationDetails)

+ (NXMConversationDetails *)conversationDetailsWithConversationId:(NSString *)conversationId {
    return [self conversationDetailsWithConversationId:conversationId sequenceId:1];
}

+ (NXMConversationDetails *)conversationDetailsWithConversationId:(NSString *)conversationId sequenceId:(NSInteger)sequenceId {
    return [self conversationDetailsWithConversationId:conversationId sequenceId:sequenceId members:nil];
}

+ (NXMConversationDetails *)conversationDetailsWithConversationId:(NSString *)conversationId sequenceId:(NSInteger)sequenceId members:(NSArray<NXMMember *> *)members {
    NXMConversationDetails * conversationDetails = [[NXMConversationDetails alloc] initWithConversationId:conversationId];
    conversationDetails.sequence_number = sequenceId;
    conversationDetails.members = members;
    return conversationDetails;
}

@end
