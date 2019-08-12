//
//  NXMTestingUtils+Members.h
//  StitchClientTests
//
//  Created by Doron Biaz on 11/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMTestingUtils.h"
#import "NXMMember.h"
#import "NXMMemberEvent.h"

@interface NXMTestingUtils (Members)


+ (NXMMember *)memberWithConversationId:(NSString *)conversationId andUserId:(NSString *)userId state:(NXMMemberState)state;
+ (NXMMember *)memberWithConversationId:(NSString *)conversationId user:(NXMUser *)user state:(NXMMemberState)state;
+ (NXMMember *)memberWithConversationId:(NSString *)conversationId user:(NXMUser *)user state:(NXMMemberState)state memberId:(NSString *)memberId;


+ (NXMMemberEvent *)memberEventWithConvId:(NSString *)convId
                                     user:(NSString *)userId
                                    state:(NSString *)state
                                 memberId:(NSString *)memberId
                             fromMemberId:(NSString *)fromMemberId
                                    media:(BOOL)media;

@end
