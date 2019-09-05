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
#import "NXMMemberEventPrivate.h"

@implementation NXMTestingUtils (Members)

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId andUserId:(NSString *)userId state:(NXMMemberState)state {
    NSString *name = [@"name_" stringByAppendingString:userId];
    NXMUser *user = [[NXMUser alloc] initWithData:@{@"id":userId, @"name":name}];
    return [self memberWithConversationId:conversationId user:user state:state];
}

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId user:(NXMUser *)user state:(NXMMemberState)state{
    NSString *memberId = [@"member_" stringByAppendingString:user.uuid];
    return [self memberWithConversationId:conversationId user:user state:state memberId:memberId];
}

+ (NXMMember *)memberWithConversationId:(NSString *)conversationId user:(NXMUser *)user state:(NXMMemberState)state memberId:(NSString *)memberId {
    
    NSDictionary *dict = @{@"media":@{@"audio_settings": @{ @"enabled":@"false", @"muted":@"false"}},
                           @"timestamp":@{},
                          @"id":user.uuid,
                          @"name":user.name,
                          @"state":state == NXMMemberStateLeft ? @"left" : state == NXMMemberStateInvited ? @"invited" : @"joined",
                          @"memberId":memberId
                           };
    
    return [[NXMMember alloc] initWithData:dict andMemberIdFieldName:@"memberId" andConversationId:conversationId];
}

+ (NXMMemberEvent *)memberEventWithConvId:(NSString *)convId
                                     user:(NSString *)userId
                                    state:(NSString *)state
                                 memberId:(NSString *)memberId
                             fromMemberId:(NSString *)fromMemberId
                                    media:(BOOL)media {
    
    NSDictionary *data = @{
                        @"user": @{
                            @"id": userId,
                            @"user_id": userId,
                            @"name": userId
                        },
                        @"channel": @{
                            @"type": @"app",
                            @"legs": @[],
                            @"leg_settings": @{}
                        },
                        @"timestamp": @{
                            state: @"2019-06-12T15:36:49.227Z"
                        },
                        @"initiator": @{
                            state: @{
                                @"isSystem": @(false),
                                @"user_id": fromMemberId,
                                @"member_id": fromMemberId
                            }
                        },
                        @"media": @{
                            @"audio_settings": @{
                                @"enabled": @(media),
                                @"earmuffed": @(false),
                                @"muted": @(false)
                            },
                            @"audio": @(media)
                        },
                    };
        
    NXMMemberEvent *event = [[NXMMemberEvent alloc] initWithConversationId:@"1"
                                                                sequenceId:1
                                                                  andState:[state isEqualToString:@"invited"] ? NXMMemberStateInvited :
                             [state isEqualToString:@"joined"] ? NXMMemberStateJoined :
                             NXMMemberStateLeft
                                                                   andData:data
                                                              creationDate:nil
                                                                  memberId:memberId];
    
    return event;
    
}
    
@end
