//
//  NXMTestingUtils+ConversationDetails.h
//  StitchClientTests
//
//  Created by Doron Biaz on 11/29/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMTestingUtils.h"

#import "NXMConversationDetails.h"

@interface NXMTestingUtils (ConversationDetails)
+ (NXMConversationDetails *)conversationDetailsWithConversationId:(NSString *)conversationId;
+ (NXMConversationDetails *)conversationDetailsWithConversationId:(NSString *)conversationId sequenceId:(NSInteger)sequenceId;
+ (NXMConversationDetails *)conversationDetailsWithConversationId:(NSString *)conversationId sequenceId:(NSInteger)sequenceId members:(NSArray<NXMMember *> *)members;
@end
