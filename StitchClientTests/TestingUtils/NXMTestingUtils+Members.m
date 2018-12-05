//
//  NXMTestingUtils+Members.m
//  StitchClientTests
//
//  Created by Doron Biaz on 11/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMTestingUtils+Members.h"

@implementation NXMTestingUtils (Members)

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId andUserId:(NSString *)userId state:(NXMMemberState)state {
    NSString *name = [@"name_" stringByAppendingString:userId];
    return [self memberWithConversationId:conversationId userId:userId state:state name:name];
}

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId userId:(NSString *)userId state:(NXMMemberState)state name:(NSString *)name {
    NSString *memberId = [@"member_" stringByAppendingString:userId];
    return [self memberWithConversationId:conversationId userId:userId state:state name:name memberId:memberId];
}

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId userId:(NSString *)userId state:(NXMMemberState)state name:(NSString *)name memberId:(NSString *)memberId {
    return [[NXMMember alloc] initWithMemberId:memberId conversationId:conversationId userId:userId name:name state:state];
}

@end
