//
//  NXMTestingUtils+Members.h
//  StitchClientTests
//
//  Created by Doron Biaz on 11/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMTestingUtils.h"
#import "NXMMember.h"

@interface NXMTestingUtils (Members)

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId andUserId:(NSString *)userId state:(NXMMemberState)state;
+ (NXMMember *)memberWithConversationId:(NSString *)conversationId userId:(NSString *)userId state:(NXMMemberState)state name:(NSString *)name;
+ (NXMMember *)memberWithConversationId:(NSString *)conversationId userId:(NSString *)userId state:(NXMMemberState)state name:(NSString *)name memberId:(NSString *)memberId;

@end
