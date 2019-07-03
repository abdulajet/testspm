//
//  NXMTestingUtils+Members.m
//  StitchClientTests
//
//  Created by Doron Biaz on 11/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMTestingUtils+Members.h"
#import "NXMUserPrivate.h"
#import "NXMMemberPrivate.h"

@implementation NXMTestingUtils (Members)

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId andUserId:(NSString *)userId state:(NXMMemberState)state {
    NSString *name = [@"name_" stringByAppendingString:userId];
    NXMUser *user = [[NXMUser alloc] initWithData:@{@"id":userId, @"name":name}];
    return [self memberWithConversationId:conversationId user:user state:state];
}

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId user:(NXMUser *)user state:(NXMMemberState)state{
    NSString *memberId = [@"member_" stringByAppendingString:user.userId];
    return [self memberWithConversationId:conversationId user:user state:state memberId:memberId];
}

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId user:(NXMUser *)user state:(NXMMemberState)state memberId:(NSString *)memberId {
    
    NSDictionary *dict = @{@"media":@{@"audio_settings": @{ @"enabled":@"false", @"muted":@"false"}},
                           @"timestamp":@{},
                          @"id":user.userId,
                          @"name":user.name,
                          @"state":state == NXMMemberStateLeft ? @"left" : state == NXMMemberStateInvited ? @"invited" : @"joined",
                          @"memberId":memberId
                           };
    
    return [[NXMMember alloc] initWithData:dict andMemberIdFieldName:@"memberId" andConversationId:conversationId];
}

@end
